-- ОБРАТНАЯ ПЕРЕОЦЕНКА И ВОЗВРАТ.
CREATE procedure RetroB.BasUnReassesment @ID int, @Qty decimal(10,3), @op int, @KolError int out, -- обратная переоценка и возврат (возможно, частичный)
  @ServiceFlag bit=0, 
  @BPMID int=0, -- если BPMID задан, то переоценка делается именно по нему. Если нет, то подбирается из исходной переоценки в IZMEN
  @Remark varchar(40)='', -- комментарий к возврату, не к переоценке
  @irID smallint=0 -- Причина возврата, см. IzmenReason
as
declare @IzmID int, @Comp varchar(30), @StartID int, 
  @Cost0 decimal(15,5), @NewCost decimal(15,5),@Cost decimal(15,5),  @Price decimal(15,5),   
  @OrigWeight decimal(10,3), @ActualWeight decimal(10,3), 
  @Sklad smallint, @Ncom int, @Dck int, @KsID int,@Pin int, @Our_ID smallint, @Ncod int, 
  @stnom int, @btid int, @P_ID int, @Hitag int, @Rest int, @IrId2 int, @NewID int, @SerialNom int, @Count int,
  @PersFam varchar(100), @Delta1 decimal(10,2), @Total decimal(10,2),
  @Fam varchar(30), @RemarkPlat varchar(30),
  @SourDate datetime, @ND datetime, @PRID int,
  @Nds smallint, @DeltaSC decimal(10,2), @flgWeight bit, @NomenNetto decimal(10,3), 
  @BaseCost decimal(15,5), @FinalCost decimal(15,5)
  
BEGIN
  begin TRANSACTION T;
  set @KolError=0;
  set @Comp=HOST_NAME();
  set @SerialNom=0;
  set @ND=dbo.today();
 
  -- Исходные данные:
  -- в момент переоценки исходная цена товара была Cost, новая стала NewCost в табл. Izmen
  -- Вес товара Weight был 0 (т.е. товар штучный) или какой-то ненулевой (весовой товар), тоже в Izmen.
  -- Соответственно исходная цена 1 кг товара, если товар весовой, была Cost/Weight, а для штучных товаров она не представляет интереса.
  -- Сейчас нужно сделать обратную переоценку.  Для штучного товара новая цена должна стать равна исходной Cost,
  -- а для весового равна (текущий вес)*(исходная цена 1 кг)

  -- Текущие данные по товару:
  select @Hitag=Hitag, @StartID=StartID, @Sklad=Sklad, @ActualWeight=weight, @Rest=Morn-Sell+Isprav-Remov, 
    @Price=Price, @Cost=Cost, @Ncom=Ncom, @Dck=Dck, @Ncod=Ncod, @Our_ID=OUR_ID
    from tdvi where id=@ID;
  select @SourDate=Comman.[date], @Pin=def.pin, @fam=left(def.brname,30) from def inner join Comman on def.ncod=comman.Ncod where comman.ncom=@Ncom;
  select @Nds=nds, @NomenNetto=Netto from nomen where Hitag=@Hitag;
  PRINT('Текущая цена товара @COST='+cast(@cost as varchar)+', текущий остаток @REST='+cast(@rest as varchar));

  /**********************************************************************************  
   **  Если ценовая спецификация не задана, она будет подобрана автоматически:      *
   **********************************************************************************/
  if @BPMID=0 
  BEGIN
    if (@Rest>=@Qty) begin
        -- Исходные данные по товару, на момент первой переоценки:
      select top 1 @IzmID=izmId,  @Cost0=cost,  @Price=Price,
        @OrigWeight=isnull(Weight,0), @Irid=IrId -- это вес в момент переоценки и номер строки в Izmen.
      from izmen where Act='ИзмЦ' and id=@StartId and remark='reassessment' order by nd;
      -- Предположим, что-то нашлось, первая переоценка действительно была:
      if  (@IzmId is not null) begin -- была какая-то переоценка:
        if @OrigWeight=0 set @NewCost=@Cost0; -- штучный товар
        else begin
           if @ActualWeight=0 set @ActualWeight=@NomenNetto;
           set @NewCost=@ActualWeight * @Cost0 / @OrigWeight; -- весовой товар
        end;
  		  -- Для начала переоцениваем весь остаток товара по заданной строке:
  		  PRINT('Подготовка переоценки, @iZMid='+CAST(@IZMID as VARCHAR)+', @NewCost='+cast(@NewCost as varchar));
  		  exec dbo.ProcessSklad
  				'ИзмЦ',@ID,@Hitag,@Sklad,             --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
  				@Price, @NewCost, @Rest, @Op,@Comp,   --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
  				@IrId, @ServiceFlag, 0,        --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  				0,0,                --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  				0,                  --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  				'UnReassessment', @NewId,               --  @remark varchar(40), @Newid int out, 
  				@SerialNom,         --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  				@kolError, 0, 0,    --  @kolError int out, @Dck INT=0, @Junk int=0, 
  				0;                  --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
      end; -- if  (@IzmId is not null)
  
  
      -- Теперь делаем возврат поставщику уже по новой цене. Или по старой, если переоценки не было:
      PRINT('Подготовка возврата, @Qty='+cast(@qty as varchar)+', @NewCost='+cast(@NewCost as varchar));
      exec dbo.ProcessSklad
        'Снят',@ID,@Hitag,@Sklad,             --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
        @Price, @NewCost, @Qty, @Op,@Comp,   --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
        @IrId, @ServiceFlag, 0,        --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
        0,0,                --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
        0,                  --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
        'UnReassessment', @NewId,               --  @remark varchar(40), @Newid int out, 
        @SerialNom,         --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
        @kolError, 0, 0,    --  @kolError int out, @Dck INT=0, @Junk int=0, 
        0;                  --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
      set @DeltaSC = @Qty*(@NewCost-@Cost);
      -- Всё, что осталось, переоцениваем как было:
      if (@IzmId is not null) and (@Rest>@Qty) 
  		BEGIN
        PRINT('Подготовка обратной переоценки, @iZMid='+CAST(@IZMID as VARCHAR)+', @Cost='+cast(@Cost as varchar));
        exec dbo.ProcessSklad
          'ИзмЦ',@ID,@Hitag,@Sklad,          --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
          @Price, @Cost, @Qty, @Op,@Comp,   --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
          @IrId2, @ServiceFlag, 0,        --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
          0,0,                --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
          0,                  --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
          'UnReassessment', @NewId,               --  @remark varchar(40), @Newid int out, 
          @SerialNom,         --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
          @kolError, 0, 0,    --  @kolError int out, @Dck INT=0, @Junk int=0, 
          0;                  --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
      end; -- if (@IzmId is not null) and (@Rest>@Qty)
      else PRINT('Обратная переоценка не требуется, поскольку товар возвращен поставщику полностью.');
  
      -- Если первая переоценка была, записываем операцию в кассу, возврат денег от поставщика, с учетом НДС:
      if @IzmId is not NULL 
  		BEGIN
        EXEC dbo.KassaAdd -1, 'ВЫ', @SourDate, @Ncom, @DeltaSC, @Fam, 0, 
          0, 0, @Ncod, 'unReassessment', 1, 0, 0, @Op, 
          0, @Our_ID, @ND, 0, 0, 0, '', 0, 
          0, 0, 0, 0, 0, null, 
          0, @Nds, null, @pin, 0, 0, @DCK, null,0, @ksid ; 
        -- Теперь раскидываем по корзинкам:
        set @BPMID=(select p.BPMid
            from retrob.BasInpdet i inner join retrob.BasPrices p on p.prid=i.prID
            where i.StartId=@startid);
  
        DECLARE c2 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
          select brd.btid, bt.p_id, left(p.fio,30), round(@DeltaSC*0.01*brd.perc,2) as Delta1
          from 
            retrob.BasRuleDistr brd 
            inner join retrob.BasTarget bt on bt.btID=brd.btid
            left join Person P on P.P_ID=bt.p_id
          where brd.bpmid=@BPMID
          group by brd.btid, bt.p_id, p.fio, brd.perc;
        open C2;
        set @Total=0.00;
        set @Count=0;
        fetch NEXT from c2 INTO @btid, @P_ID, @PersFam, @Delta1;
        WHILE @@FETCH_STATUS = 0 BEGIN
          set @RemarkPlat='btid='+cast(@btid as varchar); -- во второй коммент запишем номер корзинки.

          if @p_id>0 set @stnom=100*@P_ID+11; else set @stnom=0;
          
          EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, @PersFam, 
              @P_ID,  0, 0, 0, 
              'unReassessment', 0, 0, 0, @Op, 
              0, @Our_ID, @ND, 0, 0, 0, '', 0, 
              0, 0, 0, @stnom, 0, null, 
              0, @Nds, @RemarkPlat, 0, 0, 0, 0, null,0, @ksid ;
          set @count=@Count+1
          if @@Error<>0 set @KolError=@KolError | 4;
          set @total=@total+@delta1;
          fetch NEXT from c2 INTO @btid, @P_ID, @PersFam, @Delta1;
        end;
        close c2;
        deallocate c2;
        set @Delta1=round(@DeltaSC-@total,2);
        if abs(@Delta1)>0.005
        EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, 'коррекция расхождений', 
  				-1,  0, 0, 0, 
  				'unReassessment', 0, 0, 0, @Op, 
  				0, @Our_ID, @ND, 0, 0, 0, '', 0, 
  				0, 0, 0, 0, 0, null, 
            0, @Nds, '', 0, 0, 0, 0, null,0, @ksid ;
      end;
    end; -- if (@Rest>=@Qty)
    else PRINT('Недостаточный остаток для возврата');
  end;

  /**********************************************************************************  
  **  Если ценовая спецификация задана, ориентируемся на нее:                       *
  **********************************************************************************/
  else BEGIN
    set @KolError=0;
    set @Prid=0;
    set @NewCost=@Cost; -- возможно, цена не изменится вообще.

    -- Есть данные для обратной переоценки?
    select top 1 @BaseCost=BaseCost, @FinalCost=FinalCost, @Prid=Prid, @flgWeight=flgWeight
      from retrob.basprices bp
      where (bp.finalcost<>0 or bp.finalcost<>0)
      and  bp.basecost<>bp.finalcost
      and BPMID=@BPMID
      and bp.Hitag=@Hitag;

    if @prid is null PRINT('НЕТ ДАННЫХ ДЛЯ ОБРАТНОЙ ПЕРЕОЦЕНКИ ПО BPMID='+cast(@bpmid as varchar));
    else BEGIN
      PRINT('ЕСТЬ КАКИЕ-ТО ДАННЫЕ ДЛЯ ОБРАТНОЙ ПЕРЕОЦЕНКИ ПО BPMID='+cast(@bpmid as varchar));
      PRINT('@BaseCost='+cast(@BaseCost as varchar)+', @FinalCost='+cast(@FinalCost as varchar)
           +', @PRID='+cast(@PRID as varchar));
      -- В момент прихода цена была изменена с FinalCost до BaseCost. теперь надо сделать наоборот.
      set @NewCost=@FinalCost; -- для штучного товара.
      -- Есть нюанс: для весового товара (и для штучного, от которого отпилен весовой кусок) цену надо скорректировать.
      if @ActualWeight>0 begin -- фактически это весовой товар! Скорректируем расчетную цену:
        if @flgWeight=0 and @NomenNetto>0 set @NewCost=@NewCost*@ActualWeight/@NomenNetto;
        else if @flgWeight=1 set @NewCost=@NewCost*@ActualWeight;
        print('Расчетная новая цена изменена в соответсвии с весом='+cast(@actualWeight as varchar)
             +' и равна '+cast(@NewCost as varchar));
      end;
      
      if abs(@NewCost-@Cost)>=0.01 BEGIN -- Для начала переоцениваем весь остаток товара по заданной строке:
  		  PRINT('Подготовка переоценки');
  		  exec dbo.ProcessSklad
  				'ИзмЦ',@ID,@Hitag,@Sklad,             --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
  				@Price, @NewCost, @Rest, @Op,@Comp,   --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
  				@IrID, @ServiceFlag, 0,        --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  				0,0,                --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  				0,                  --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  				'UnReassessment', @NewId,               --  @remark varchar(40), @Newid int out, 
  				@SerialNom,         --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  				@kolError, 0, 0,    --  @kolError int out, @Dck INT=0, @Junk int=0, 
  				0;                  --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
        set @DeltaSC = @Rest*(@NewCost-@Cost);

        -- В соответствии с переоценкой записываем выплату поставщику:
        EXEC dbo.KassaAdd -1, 'ВЫ', @SourDate, @Ncom, @DeltaSC, @Fam, 0, 
          0, 0, @Ncod, 'unReassessment', 1, 0, 0, @Op, 
          0, @Our_ID, @ND, 0, 0, 0, '', 0, 
          0, 0, 0, 0, 0, null, 
          0, @Nds, null, @pin, 0, 0, @DCK, null,0, @ksid ; 
        
        -- Теперь раскидываем по корзинкам, BPMID нам задан:
        DECLARE c2 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
          select brd.btid, bt.p_id, left(p.fio,30), round(@DeltaSC*0.01*brd.perc,2) as Delta1
          from 
            retrob.BasRuleDistr brd 
            inner join retrob.BasTarget bt on bt.btID=brd.btid
            left join Person P on P.P_ID=bt.p_id
          where brd.bpmid=@BPMID
          group by brd.btid, bt.p_id, p.fio, brd.perc;
        open C2;
        set @Total=0.00;
        set @Count=0;
        fetch NEXT from c2 INTO @btid, @P_ID, @PersFam, @Delta1;
        WHILE @@FETCH_STATUS = 0 BEGIN
          set @RemarkPlat='btid='+cast(@btid as varchar); -- во второй коммент запишем номер корзинки.
          set @stnom = 100 * @P_ID + 11;
          EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, @PersFam, 
              @P_ID,  0, 0, 0, 
              'unReassessment', 0, 0, 0, @Op, 
              0, @Our_ID, @ND, 0, 0, 0, '', 0, 
              0, 0, 0, @stnom, 0, null, 
              0, @Nds, @RemarkPlat, 0, 0, 0, 0, null,0, @ksid ;
          set @count=@Count+1
          if @@Error<>0 set @KolError=@KolError | 4;
          set @total=@total+@delta1;
          fetch NEXT from c2 INTO @btid, @P_ID, @PersFam, @Delta1;
        end;
        close c2;
        deallocate c2;
        set @Delta1=round(@DeltaSC-@total,2);
        if abs(@Delta1)>=0.005
        EXEC dbo.KassaAdd 10, 'ВЫ', @SourDate, 0, @Delta1, 'коррекция расхождений', 
  				-1,  0, 0, 0, 
  				'unReassessment', 0, 0, 0, @Op, 
  				0, @Our_ID, @ND, 0, 0, 0, '', 0, 
  				0, 0, 0, 0, 0, null, 
          0, @Nds, '', 0, 0, 0, 0, null,0, @ksid ;
      end; -- БЫЛА СДЕЛАНА ПЕРЕОЦЕНКА
      else print('Поскольку цена изменилась несущественно, с '+cast(@cost as varchar)+' на '+cast(@NewCost as varchar)+', переценки не будет.')
    end; -- if @prid is not null
    -- Теперь делаем возврат всего остатка поставщику уже по новой цене. Или по старой, если переоценки не было:
    PRINT('Подготовка возврата, @rest='+cast(@rest as varchar)+', @NewCost='+cast(@NewCost as varchar));
    exec dbo.ProcessSklad
      'Снят',@ID,@Hitag,@Sklad,             --  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
      @Price, @NewCost, @rest, @Op,@Comp,   --  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
      @IrId, @ServiceFlag, 0,        --  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
      0,0,                --  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
      0,                  --  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
      @Remark, @NewId,    --  @remark varchar(40), @Newid int out, 
      @SerialNom,         --  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
      @kolError, 0, 0,    --  @kolError int out, @Dck INT=0, @Junk int=0, 
      0;                  --  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
  end; -- БЫЛА ЗАДАНА СПЕЦИФИКАЦИЯ
  if @KolError=0 commit transaction T;
  else ROLLBACK TRANSACTION T;
end;