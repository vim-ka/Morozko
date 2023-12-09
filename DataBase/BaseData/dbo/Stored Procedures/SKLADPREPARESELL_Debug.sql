CREATE PROCEDURE dbo.SKLADPREPARESELL_Debug -- для отладки: 0,it4,21817,0.45,47,1611223777,0, 0,0,0
  @ACTION TINYINT=0, -- 0 - НАБОР
  @COMP VARCHAR(30),
  @HITAG INT,
  @VES DECIMAL(10,3),
  @SKLADLIST VARCHAR(200),
  @DATNOM INT, 
  @OP INT, 
  @KOLERROR INT OUT,
  @SPK INT=0,
  @nzid INT=0
  WITH RECOMPILE
AS
declare @id int, @junk int, @newid int, @lastizmid int, @lastid int, @origid int, @origweight decimal(10,3),
  @price decimal(10,2), @cost decimal(13,5), @newprice decimal(10,2), @newcost decimal(13,5), 
  @sklad int, @newsklad int, @ss varchar(100), @tekweight decimal(10,3), @tekkol decimal(10,3),
  @procerror int, @unionweight decimal(10,3), @qty int, @origqty int, @firmgroup int,  @ok bit, @msg varchar(max),
  @head varchar(256), @tran varchar(20),@kol int, @b_id int, @ag_id int, @Dck int, @StfNom varchar(17),@StfDate datetime,
  @DocNom varchar(20),@DocDate datetime, @NewDatnom int, @Tekid int, @Zakaz decimal(10,3),@SavedZakaz decimal(10,3),
  @Our_ID smallint, @Srok int, @Pko bit,@Man_Id int, @TovChk bit, @Actn bit, @Ck tinyint, @B_Id2 int,@Stip smallint,
  @NeedDover2 bit, @QtyNakl int, @Fam varchar(35)

BEGIN
  SET NOCOUNT ON
  SET @KOLERROR=0
  SET @PROCERROR=0
  SET @MSG=''
  IF isnull(@nzid,0)=0 set @nzid=(SELECT top 1 nzid FROM nvZakaz z WHERE z.datnom=@DATNOM AND z.Hitag=@HITAG AND z.Done=0);

PRINT '@NZID='+cast(@nzid as varchar)

      
  SELECT @KOL=z.zakaz 
  FROM nvZakaz z 
  WHERE z.nzid=@nzid
PRINT '@KOL='+cast(@kol as varchar)+'   @VES='+cast(@VES as varchar)

   
  IF @VES>0 AND @KOL>0
  BEGIN
	  DELETE FROM PARAMSKLAD WHERE COMP=@COMP;
		SET @TRAN='SKLADPREPARESELL'
		BEGIN TRANSACTION @TRAN
		
	  
    SET @FIRMGROUP=(SELECT F.FIRMGROUP FROM NC C JOIN FIRMSCONFIG F ON C.OURID=F.OUR_ID WHERE C.DATNOM=@DATNOM)
	  
    SELECT @TEKWEIGHT=SUM(V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV-V.REZERV)) 
		FROM TDVI V
		WHERE V.SKLAD IN (SELECT K FROM DBO.STR2INTARRAY(@SKLADLIST))
				  AND V.HITAG=@HITAG
PRINT '@TEKWEIGHT='+cast(@TEKWEIGHT as varchar)
    	 
	  -- подбор точного совпадения веса остатка товара с заказанным весом:
	  select top 1 @id=v.id,
                 @origid=v.id, 
                 @sklad=v.sklad, 
                 @origweight=v.weight*(v.morn-v.sell+v.isprav-v.remov),
		             @price=v.price, 
                 @cost=v.cost, 
                 @unionweight=v.weight, 
                 @origqty=(v.morn-v.sell+v.isprav-v.remov)
	  from tdvi v 
    join firmsconfig f on v.our_id=f.our_id
	  where v.hitag=@hitag 
          and v.weight>0
			    and v.sklad in (select k from dbo.str2intarray(@skladlist))
			    and abs(v.weight*(v.morn-v.sell+v.isprav-v.remov)-@ves)<0.001
          and v.locked=0 
          and (v.morn-v.sell+v.isprav-v.remov)>0
			    and f.firmgroup=@firmgroup
          and v.id>0
	  order by v.srokh;

-- Это для отладки:
if @id is null print 'Не удалось подобрать точный вес';
else print 'Что-то удалось подобрать с совпадающим весом! @OrigId='+cast(@OrigId as varchar);

    if @id is null 
      set @ok=0
	  else begin  
			set @ok=1
			set @lastid=@origid
			set @newcost=@cost
			set @newprice=@price
			set @newsklad=@sklad
			set @qty=@origqty -- количество в штуках равно остатку
	  end;
  		
	  -- Если не удалось подобрать точный вес, пытаемся подобрать кратный 
    -- (например, заказано 7.5 кг, и есть строка с весом 1шт = 2.5кг и остатком не менее 3):
	  if @ok=0 
    begin
			select top 1 @id=id,
				           @origid=v.id, 
                   @sklad=v.sklad, 
                   @origweight=v.weight*(v.morn-v.sell+v.isprav-v.remov),
				           @price=v.price, 
                   @cost=v.cost, 
                   @unionweight=v.weight, 
                   @origqty=(v.morn-v.sell+v.isprav-v.remov),
				           @qty=round(@ves/v.weight,0) -- можно продать @qty штук
			from tdvi v join firmsconfig f on v.our_id=f.our_id
			where v.hitag=@hitag 
            and v.weight>0
				    and v.sklad in (select k from dbo.str2intarray(@skladlist))
				    and @ves % v.weight=0
				    and v.weight*(v.morn-v.sell+v.isprav-v.remov)>=@ves 
            and v.locked=0 
            and (v.morn-v.sell+v.isprav-v.remov)>0
				    and f.firmgroup=@firmgroup
            and v.id>0
			order by v.srokh;  
			
      if @id is null 
        set @ok=0
			else begin
				set @ok=1
				set @lastid=@origid
				set @newcost=@cost
				set @newprice=@price
				set @newsklad=@sklad       
			end;
	  end;

    
    
              
		-- Если не удалось подобрать ни точный вес, ни кратный, ищем строку с большим суммарным весом:
	  if @ok=0 
    begin
		  select top 1 @id=v.id,
			             @origid=v.id, 
                   @sklad=v.sklad, 
                   @origweight=v.weight*(v.morn-v.sell+v.isprav-v.remov),
			             @price=v.price, 
                   @cost=v.cost, 
                   @unionweight=v.weight, 
                   @origqty=(v.morn-v.sell+v.isprav-v.remov)
		  from tdvi v join firmsconfig f on v.our_id=f.our_id
		  where v.hitag=@hitag 
            and v.weight>0
				    and v.sklad in (select k from dbo.str2intarray(@skladlist))
				    and v.weight*(v.morn-v.sell+v.isprav-v.remov)>@ves 
				    and v.locked=0 
            and (v.morn-v.sell+v.isprav-v.remov)>0
				    and f.firmgroup=@firmgroup
            and v.id>0
		  order by v.weight desc, v.srokh
		  
      -- Это для отладки:
      if @ID is null
      print 'Подбор большего веса: неудачно!';
      else print 'Подбор большего веса: что-то получилось! ID товара равен '+cast(@ID as varchar);

		  if @id is null 
        set @ok=0
		  else begin
				set @ok=1;
				set @qty=ceiling(@ves/@unionweight);

				-- КАКУЮ СТРОКУ РАСПИЛИТЬ:
				INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
				VALUES (@COMP,  'DIV-',  @ORIGID,  @HITAG,  @SKLAD,  @UNIONWEIGHT,  @PRICE,  @COST, 0,  @QTY);
				IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+2;

				-- НОВАЯ СТРОКА С ОСТАТКОМ ПРИ ЕДИНИЧНОМ ИСХОДНОМ КОЛИЧЕСТВЕ:
			  IF @ORIGQTY=1 BEGIN
					INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
					VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  @UNIONWEIGHT-@VES,  
						@PRICE/@UNIONWEIGHT*(@UNIONWEIGHT-@VES), @COST/@UNIONWEIGHT*(@UNIONWEIGHT-@VES), 1,  1);
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+4; 
			  END
				ELSE BEGIN
					INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
					VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  
						@UNIONWEIGHT*@QTY-@VES,  
						@PRICE/@UNIONWEIGHT*(@UNIONWEIGHT*@QTY-@VES),  
						@COST/@UNIONWEIGHT*(@UNIONWEIGHT*@QTY-@VES), 1,  1);
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+8; 
				END;
			 
			  -- ВТОРАЯ НОВАЯ СТРОКА, ЭТО БУДЕТ ПРОДАНО:
			  INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
			  VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  @VES,  
					@PRICE*@VES/@UNIONWEIGHT,  @COST*@VES/@UNIONWEIGHT, 2,  1);
			  IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+16

				SET @JUNK=0; SET @NEWID=0;
        
        -- Это для отладки:
        print 'Перед вызовом ProcessSklad: @KolError='+cast(@kolerror as varchar);
  
				IF @KOLERROR=0 
				BEGIN
          SET @PROCERROR=-1;
 				  EXEC PROCESSSKLAD 'DIV-', NULL, @HITAG, NULL, 
							NULL, NULL, 0, @OP, @COMP,
							NULL, 0, 1,  0, 0,0,
							'ПРОДАЖА НА ВЕС', @NEWID OUTPUT,  0,
							@PROCERROR OUTPUT, NULL, @JUNK,NULL;        
          IF ISNULL(@PROCERROR,0)<>0 OR ISNULL(@NEWID,0)=0
						 SET @KOLERROR=@KOLERROR+32;
				END 
-- Это для отладки:
print 'После вызова ProcessSklad: @KolError='+cast(@kolerror as varchar)+'  @ProceError='+cast(@ProcError as varchar);		
			
				IF @KOLERROR=0 
				BEGIN
					SET @LASTID=@NEWID;
					-- SELECT @LASTID=NEWID, @NEWCOST=NEWCOST, @NEWPRICE=NEWPRICE, @NEWSKLAD=NEWSKLAD FROM IZMEN WHERE IZMID=@LASTIZMID;
					SELECT @NEWCOST=COST, @NEWPRICE=PRICE, @NEWSKLAD=SKLAD FROM TDVI WHERE ID=@NEWID;
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+64;
					SET @QTY=1;
-- Это для отладки:
print 'Новый товар, который будет добит сейчас: LastId='+cast(@LastID as varchar);
				END
			END
-- Это для отладки:
print '-- КОНЕЦ БЛОКА ПОДБОРА ЛЮБОГО ВЕСА.'
		END;  -- КОНЕЦ БЛОКА ПОДБОРА ЛЮБОГО ВЕСА.


    -- ОПЕРАЦИИ ПОСЛЕ ПОДБОРА:

		IF @OK=0 SET @KOLERROR=1;

    -- Вот этот блок здесь явно лишний! Пересчет tdvi.sell выполнит сама SAVENAKL !
    --	  IF @KOLERROR=0 BEGIN
    --			UPDATE TDVI SET SELL=SELL+@QTY WHERE ID=@LASTID
    --			IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+128;      
    --print 'Пересчет TDVI.Sell выполнен, @KolError='+cast(@KolError as varchar);
    --	  END;
	    
  	if @kolerror=0 begin
print 'ВХОД в режим собственно добивки...';
      if @datnom<dbo.fnDatNom(dbo.today(),0) begin --вчерашняя или еще более ранняя накладная:
        -- Запоминаем данные по исходной накладной:
        select @Dck=dck, @B_ID=b_id,@Our_ID=OurID, @ag_id=ag_id, @StfNom=StfNom,@StfDate=stfDate,@DocNom=DocNom,@DocDate=DocDate,
          @Srok=Srok, @Pko=Pko, @Man_ID=Man_Id, @Tovchk=Tovchk, @Actn=Actn, @Ck=Ck,@B_Id2=B_Id2, @Stip=Stip,@NeedDover2=NeedDover,
          @Fam=Fam
        from nc where datnom=@datnom;

        -- Уже есть подходящая добивочная накладная за сегодня?
        -- Черт, а почему ж вот это отменено? Вернул назад! - Виктор, 28.11.2016
        set @NewDatnom=(select top 1 datnom from nc where nd=dbo.today() and Refdatnom=@Datnom and Dck=@Dck and b_id=@b_id and ag_id=@ag_id and SP>=0);
 		    -- set @NewDatnom=(select top 1 newdatnom from nvzakaz where isnull(NewDatnom,0)<>0 and datnom=@datnom); -- вызывает сомнение. Это может оказаться вчерашняя добивка!

        if isnull(@NewDatnom,0)=0
        begin -- нет, придется завести:
          set @Tekid=@LASTID
          set @Zakaz=@kol
          set @Sklad=@NEWSKLAD
          set @Price=@NEWPRICE

PRINT 'СЕЙЧАС БУДЕТ ВЫЗВАН SAVEZAKAZ для одной строки @TekID='+cast(@tekid as varchar)
          exec dbo.SaveZakaz @COMP, @Hitag, @TekID, @Zakaz, 
            @Sklad, @SavedZakaz, @Price, 
            null, null, null, 1,
            @DCK, @StfNom, @StfDate, 
            @DocNom, @DocDate,
            0, 1, 1;
PRINT 'OK, SAVEZAKAZ исполнен';

PRINT 'СЕЙЧАС БУДЕТ ВЫЗВАН SAVENAKL';
          exec dbo.SaveNakl 
            @Comp, @B_ID, @Fam,
            @Our_ID, @Ag_ID, @OP,  @Srok,   
            @Pko,  @Man_ID, @tovchk,  'добивка',  @Actn, 
            @Ck, 0, @DatNom, 0, @NewDatNom output, 
            0,  '',  null, 
            '', @DCK, @B_ID2, @NeedDover2,
            @Stip,0, 0, @PROCERROR OUTPUT, @NeedDover2,
            @QtyNakl output-- в результате появится накладная с номером @NewDatnom и одной строкой внутри NV.
PRINT 'OK, SAVENAKL исполнен так или иначе. @NewDatnom='+cast(@newdatnom as varchar)+'  @ProcError='+cast(@procerror as varchar);
  
                        
            
          if @PROCERROR<>0 set @kolerror=@kolerror+5096
					if @QtyNakl=0 set @kolerror=@kolerror+10182
          
          -- Сдается мне, следующую строку надо переделать. У нас же @nzid известен:
          -- update nvzakaz set newdatnom=@NewDatNom where isnull(NewDatnom,0)=0 and DatNom=@DatNom and hitag=@hitag
          update nvzakaz set newdatnom=@NewDatNom where nzid=@nzid; -- вот так точно не зацепишь лишнее. - Виктор

          update nc set RefDatnom=@DatNom where DatNom=@NewDatNom
        end;
        else -- уже есть накладная, впиливаем строку в нее:
          insert into nv(datnom,tekid,hitag,sklad,price,cost,kol,tip)
          values(@Newdatnom, @lastid, @hitag, @newsklad, @newprice, @newcost, @qty, 0);
      end;





      else BEGIN -- сегодняшняя накладная:
        PRINT 'Ну вот сюда-то, в ветку сегодняшней накладной, отладка никак не может попасть при этих данных!'
        set @tekkol=(select kol from nv where datnom=@datnom and tekid=@lastid);
        if @tekkol is null 
          insert into nv(datnom,tekid,hitag,sklad,price,cost,kol,tip)
                values(@datnom, @lastid, @hitag, @newsklad, @newprice, @newcost, @qty, 0);
        else if @tekkol=0
          update nv set hitag=@hitag, sklad=@newsklad,price=@newprice,cost=@newcost, 
          kol=@qty, tip=0 where datnom=@datnom and tekid=@lastid;
        else set @kolerror=@kolerror+512;      
   			if @kolerror=0 begin
          UPDATE TDVI SET SELL=SELL+@QTY WHERE ID=@LASTID
   			  IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+128;      
        end;
        print 'Пересчет TDVI.Sell выполнен, @KolError='+cast(@KolError as varchar);
      end;

	  end; -- if @kolerror=0
    
    IF @KOLERROR=0 
	  BEGIN    
	      UPDATE NVZAKAZ SET DONE=1,
		                       TMEND=CONVERT(VARCHAR(8),GETDATE(),108),
			                     DTEND=dbo.today(),
			                     CURWEIGHT=@VES,
			                     TEKWEIGHT=@TEKWEIGHT,
			                     ID=@LASTID,
			                     COMP=left(COMP+'#'+@COMP,256), -- Это я добавил! Мало ли что! - Виктор.
                           OP=@OP,
                           SPK=@SPK
        where nzid=@NZID;
        -- А было вот так:
		    --  WHERE DATNOM=@DATNOM
        --      AND HITAG=@HITAG 
        --      AND DONE=0; 
	      
        IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+1024;	             
	  END; -- if @kolerror=0

		
		IF @KOLERROR=0 
		BEGIN
			IF EXISTS(SELECT * FROM NC WHERE DATNOM=@DATNOM AND  NOT MARSH IN (0,99))
			BEGIN
				DECLARE @M INT
				DECLARE @N DATETIME 
				
				SELECT @M=MARSH, @N=ND
				FROM NC 
				WHERE DATNOM=@DATNOM
				
				UPDATE MARSH SET WEIGHT=WEIGHT+@VES, BRUTTOWEIGHT=BRUTTOWEIGHT+@VES
				WHERE MARSH=@M AND ND=@N
        IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+1024;                       
			END
		END;		 -- if @kolerror=0
	END
  
  --обработка заявок на разбор
  IF @KOL<0 
    UPDATE NVZAKAZ SET DONE=1,
      TMEND=CONVERT(VARCHAR(8),GETDATE(),108),
      DTEND=CONVERT(VARCHAR(10),GETDATE(),104),
      CURWEIGHT=@VES,
      COMP=COMP+'#'+@COMP,
      OP=@OP,
      SPK=@SPK
  		WHERE nzid=@nzid;
      -- А раньше было вот так:
      -- where DATNOM=@DATNOM 
      --   AND HITAG=@HITAG 
      --  AND DONE=0

  IF @KOLERROR=0 begin
    COMMIT TRANSACTION @TRAN; 
    SET @HEAD='SKLADPREPARESELL::'+@COMP+'::COMMIT'      
  end;
  else begin      
    ROLLBACK TRANSACTION @TRAN;
    INSERT INTO PROCERRORS(ERRNUM, ERRMESS, PROCNAME, ERRLINE) SELECT ERROR_NUMBER(), ERROR_MESSAGE(), OBJECT_NAME(@@PROCID), ERROR_LINE()  
  end;
  SET NOCOUNT OFF;
END