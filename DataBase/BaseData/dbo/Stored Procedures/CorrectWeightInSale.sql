-- коррекция веса, параметры в табл. CorrWeightParams:
create procedure dbo.CorrectWeightInSale @datnom int, @OP int, @ErrCode smallint out 
/*
   Коррекция веса внутри существующей накладной.
   В результате работы появятся две новых накладных: одна возвратная и одна расходная.
   Возвращаемые коды ошибок:
     0 - ошибок нет;
     1 - для одной из исходных строк уже существует запись в TDVI, эта строка пропущена;
     2 - операция разбиения прошла неудачно;
     4 - не удалось создать заголовок новой расходной накладной.

   Дополнение от 05.09.2017:
   После выполения коррекции веса должны быть записаны также две операции по кассе,   
   закрытие исходной накладной и закрытие новой возвратной накладной, аналогично SaveBackAndSale
*/

as
declare @OrigDate datetime, @ND datetime, @TM varchar(8), @Host varchar(35), @TekID int, 
  @Weight decimal(10,3), @NewWeight decimal(10,3), @Fam varchar(100), @B_ID int,
  @StartDatnom int, @backdatnom int, @NewDatnom int, @SerialNom int, @ProcSkErr int,
  @Hitag int, @Sklad int, @Price decimal(15,5), @Cost decimal(15,5), @OrigPrice decimal(15,5), @OrigCost decimal(15,5),
  @NewID int, @Actn bit, @NcDCK int, @SP decimal(12,2), @SC decimal(12,2), @OurID int;

begin
  set @ErrCode=0;
  set @SerialNom=0;
  set @Host=HOST_NAME();
  set @OrigDate=dbo.DatNomInDate(@datnom);
  set @ND=dbo.today();
  set @TM=dbo.time();
  select @NcDCK=DCK, @Fam=Fam,@B_ID=B_ID,@StartDatnom=Startdatnom, @Actn=Actn, @OurID=OurID from nc where Datnom=@Datnom;

  delete from ParamSklad where Comp=@HOST;

  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
  begin transaction


  if @OrigDate=dbo.today() BEGIN -- для сегодняшней накладной всё гораздо проще:
    select * from CorrWeightParams
  end;

  else BEGIN -- ветка вчерашней или более ранней накладной:
    declare CurBack cursor fast_forward  
      for select tekid, weight, newweight,OrigPrice,Origcost from CorrWeightParams P where P.Host=@Host;

    open CurBack; 
    fetch next from CurBack into @TekID, @Weight, @NewWeight, @OrigPrice, @Origcost;
    if @@FETCH_STATUS=0 begin -- что-то есть:
  
      -- Номер возвратной накладной:
      set @backdatnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
      -- Номер новой расходной накладной:
      set @Newdatnom=1+@backdatnom;


      print('BackDatnom='+cast(@BackDatnom as varchar)+',  NewDatnom='+cast(@newdatnom as varchar));
      print('Пытаюсь записать заголовок возвратной накладной...');
      -- Заголовок возвратной накладной (с суммами разберемся потом):
      insert into NC (ND,datnom,StartDatnom,B_ID,B_ID2,Fam,Tm,OP,SP,SC,
        Extra,Srok,OurID,Pko,Man_ID, 
        BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
        Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
        RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip,gpOur_iD)
      select @ND, @backdatnom, @StartDatnom, B_ID, B_ID2,  Fam,@TM, @OP,0,0,
        Extra,Srok,OurID, 0, 0, 
        0,TovChk, 0, ag_id, stfnom,stfdate,0,0,
        '',0,0,0,0, actn,0,0,       
        @DatNom,0,0, 1, 0.0, '', 0, @Host, DCK, Stip,gpOur_iD
      from NC where Datnom=@Datnom;
      print('  - OK');

      -- Детализацию возвратной накладной можно заполнить одной командой, не используя курсор:
      print('Пытаюсь записать детализацию возвратной накладной...');
      insert into NV (datnom,hitag,tekid,price,cost,Kol,sklad,kol_b,baseprice,ag_id)
      select @backdatnom, nv.hitag, nv.tekid, nv.price, nv.cost, -1, nv.sklad, 0, nv.baseprice, nv.ag_id
      from 
        CorrWeightParams P
        inner join NV on NV.datnom=@Datnom and nv.TekID=p.tekid
      where p.host=@Host;
      print('  - OK');

      -- Заголовок новой расходной накладной, тоже пока без сумм:  
      print('Пытаюсь записать заголовок Заголовок новой расходной накладной...');
      insert into NC (ND,datnom,StartDatnom,B_ID,B_ID2,Fam,Tm,OP,SP,SC,
        Extra,Srok,OurID,Pko,Man_ID, 
        BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
        Remark,Printed,Marsh,MhID,BoxQty,WEIGHT,Actn,CK,Tara,
        RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift, Comp, DCK, Stip,gpOur_iD)
      select @ND, @Newdatnom, @StartDatnom, B_ID, B_ID2,  Fam,@TM, @OP,0,0,
        Extra,Srok, OurID, 0, 0, 
        0,TovChk, 0, ag_id, stfnom,stfdate,0,0,
        '',0,99,-99,0,0, actn,0,0,       
        @DatNom,0,0, 1, 0.0, '', 0, @Host, DCK, Stip, gpOur_iD
      from NC where Datnom=@Datnom;
      if (@@Error<>0) set @Errcode=@Errcode | 4;
      print('Заголовок вроде записан, код ошибки @@Error = '+cast(@@Error as varchar));

      WHILE (@@FETCH_STATUS=0) BEGIN

        -- Наверняка в склад потребуется добавить новую запись, т.е. старую, из visual:
        if exists(select * from tdvi where id=@tekid) begin 
          -- set @ErrCode=@ErrCode | 1; -- Что, уже есть? Странно! Явная ошибка.
          --          delete from NV where datnom=@Backdatnom and tekid=@tekid; -- аннулирую запись возврата
          print('Странно, в TDVI уже есть запись ID = '+cast(@tekid as varchar));
          delete from TDVI where id=@TEKID;
        end;

        print('Попытка записи в TDVI строки ID = '+cast(@tekid as varchar)+'...');
        SET IDENTITY_INSERT tdvi ON; -- отключаю автоинкремент.
        insert into tdvi(Nd,id,startid,ncom,ncod,datepost,price,start,startthis,
          hitag,sklad,cost,minp,mpu,sert_id,rang,morn,sell,isprav,remov,Bad,
          dater,srokh,country,rezerv,units,locked,Ncountry,Gtd,Vitr,Our_ID,
          WEIGHT,SaveDate,MeasID,OnlyMinP, DCK, ProducerID, CountryID, pin)
       select @Nd as ND,id,startid,ncom,ncod,datepost,price,start,0 as StartThis,
          hitag,sklad,cost,minp,mpu,sert_id,rang,0 as morn,-1 as sell,0 as isprav,0 as remov,0 as Bad, -- это возврат!
          dater,srokh,country,0 as rezerv,units,0 as locked,Ncountry,Gtd,0 as Vitr,Our_ID,
          WEIGHT,@ND as SaveDate,MeasID,0 as OnlyMinP, DCK, ProducerID, CountryID, pin
        from Visual where id=@tekid;
        SET IDENTITY_INSERT tdvi OFF; -- включаю автоинкремент.
        print('  - OK');

        print('Подготовка трех строк данных в табл. ParamSklad...');
        
        -- Теперь имеющийся вес Weight надо распилить на две части, NewWeigth и что осталось:
        delete from ParamSklad where Comp=@HOST; 
        select @Hitag=Hitag, @Sklad=Sklad, @Price=Price, @Cost=Cost from visual where ID=@Tekid;  -- Visual здесь для отладки, потом поменять на TDVI
        set @ProcSkErr=0; -- код ошибки, возвращаемый ProcessSklad.
        
        -- Для этого втыкаем в таблицу аргументов запись с NOMER=0, это исходная строка:
        INSERT INTO dbo.ParamSklad(Comp,  Act, Id, Hitag,  Sklad,  Weight,  Price,  Cost,  Nomer,  Qty,  Ncom)         
          select @Host, 'Div-', @TekID, Hitag, Sklad, @Weight, Price, Cost, 0, 1, Ncom
          from visual where id=@TekID; -- Visual здесь для отладки, потом поменять на TDVI
        print('  - Nomer=0 записана.');
        
        declare @Cost2 decimal(10,5);
        set @Cost2 = @cost * (1.00 - @NewWeight/@Weight);

        -- И еще две записи с номерами 1 и 2, это поделенные на два веса новые остатки товаров. Для них ID=0:
        INSERT INTO dbo.ParamSklad(Comp,  Act, ID, Hitag,  Sklad,  Weight,  Price,  Cost,  Nomer,  Qty,  Ncom)         
          select @Host, 'Div-', 0, Hitag, Sklad, @Weight-@NewWeight, Price*(@Weight-@NewWeight)/@Weight, @Cost2, 1, 1, Ncom
          from visual where id=@TekID;-- Visual здесь для отладки, потом поменять на TDVI
        print('  - Nomer=1 записана.');
        INSERT INTO dbo.ParamSklad(Comp,  Act, ID, Hitag,  Sklad,  Weight,  Price,  Cost,  Nomer,  Qty,  Ncom)         
          select @Host, 'Div-', 0, Hitag, Sklad, @NewWeight, Price*@NewWeight/@Weight, Cost*@NewWeight/@Weight, 2, 1, Ncom
          from visual where id=@TekID; -- Visual здесь для отладки, потом поменять на TDVI
        print('  - Nomer=2 записана.');

        print('Вызов ProcessSklad...');
        set @NewID=0;
        exec dbo.ProcessSklad 
          'Div-', null, null, null, -- @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
          0,0,0, @OP, @Host,        -- @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
          null, 0, 1,               -- @irId int, @ServiceFlag bit=0, @DivFlag bit=0,
          0,0,                      -- @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran" 
          0, 'CorrWeightInSale',@NewID,  -- @NewNcod, @Remark, @NewID ,
          @SerialNom,@ProcSkErr,0,  -- @SerialNom, @kolError int out, @Dck INT=0, 
          0, 0                      -- @Junk int=0, @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"

        print('Вызов ProcessSklad сделан, код возвращаемой ошибки '+cast(@ProcSkErr as varchar)+',  новый ид товара @NewID='+cast(@NewID as varchar));

        set @NewID=(select NewID from Paramsklad where Comp=@Host and Nomer=2);

        print('Не полагаясь на возвращаемое ProcessSklad значение @NewID, читаем его из табл. ParamSklad. Получилось @NewID='+cast(@NewID as varchar));

        -- То ли сработало, то ли нет:
        if (@ProcSkErr=0)and(isnull(@NewID,0)<>0) begin
          print('Вставка строки в NV...');
          INSERT INTO dbo.NV(DatNom,TekID,Hitag,Price,Cost,Kol,Kol_B,Sklad,BasePrice,Remark,tip,Meas,DelivCancel,OrigPrice,ag_id) 
          select top 1 @NewDatnom, @NewId, @Hitag, round(@OrigPrice*@NewWeight/@Weight,2),round(@OrigCost*@NewWeight/@Weight,5),
            1,0, @Sklad, round(BasePrice*@NewWeight/@Weight,2),
            'CorrWeightInSale', tip, meas,delivcancel, round(OrigPrice*@NewWeight/@Weight,2), ag_id
          from nv where datnom=@datnom and Tekid=@Tekid;
          print('  - OK');
          print('Обновление KOL_B в старой накладной...');
          update nv set kol_b=kol_b+1 where datnom=@datnom and Tekid=@Tekid;
          print('Обновление SELL для новой строки остатка, где ID=@NEWID='+cast(@NewID as varchar));
          update TDVI set Sell=1 where ID=@NewID;
          print('  - OK');
        end;
        else begin
          print('Вставка строки в NV отменена, поскольку ProcessSklad выдал плохой ответ.');
          set @ErrCode = @ErrCode | 2;
        end;

        fetch next from CurBack into @TekID, @Weight, @NewWeight, @OrigPrice, @Origcost;
      end; -- конец просмотра курсора
    end; -- что-то было.
  
    close CurBack;
    deallocate CurBack;

    if isnull(@BackDatnom,0)>0 exec RecalcNCSumm @Backdatnom;
    if isnull(@NewDatnom, 0)>0 exec RecalcNCSumm @NewDatnom;
    select @SP=abs(sp), @SC=abs(SC) from NC where Datnom=@BackDatnom;



    /*************************************************************************
    ** ДВЕ КАССОВЫЕ ОПЕРАЦИИ, закрытие исходной  и возвратной накладной     **
    *************************************************************************/
    if (@ErrCode=0) and (@Actn=0) begin
  	  insert into Kassa1(ND, TM,  Oper,Act,
        SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
        ForPrint, SourDatNom, DCK)
  	  values( @ND, @TM, -2,'ВО', 
        @OrigDate, dbo.innnak(@DatNom),@SP, @Fam, 0, @B_ID,0,0,
        'Возврат. См. накладную '+cast(dbo.inNnak(@backdatnom) as varchar(4))+' от '+convert(char(8), @ND,4)+' CorrWeight',
        0,1,0,
        @Op,0,@OurID,@ND,0,0,
        0, @DatNom, @NcDCK);
      if @@Error<>0 set @ErrCode = @ErrCode | 8;
    end;

    if (@ErrCode=0) and (@Actn=0) and (@backdatnom>0) begin
  	  insert into Kassa1(ND,TM, Oper,Act,
        SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
        remark, RashFlag,LostFlag,LastFlag,
        Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
        ForPrint, SourDatNom, DCK)
	    values(@ND,@TM, -2,'ВО', 
        @ND, dbo.innnak(@backdatnom),-@SP, @Fam, 0, @B_ID,0,0,
        'Возврат накладной #'+cast(dbo.inNnak(@DatNom) as varchar)+' от '+convert(char(8), @Datnom,4)+' CorrWeight',
        0,1,0,
        @Op,0,@OurID,@ND,0,0,
        0, @backdatnom, @NcDCK);
      if @@Error<>0 set @ErrCode = @ErrCode | 16;
    end;

  end; -- конец вчерашней ветки
  if @ErrCode=0 COMMIT else ROLLBACK;
  select @ErrCode as ErrCode;
end