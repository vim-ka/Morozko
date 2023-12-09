CREATE procedure dbo.ProcessNakl_debug 
  @datnom int,      -- номер накладной
  @Op int,          -- код оператора
  @flgEdit bit=1,   -- признак редактирования
  @flgDrop tinyint=0,   -- 1-признак полного возврата, 2-возврат+продажа. 
                        -- При @flgDrop=1 и отрицательной исходной сумме цены проверять не будем.
  @ErrCode int out, -- код ошибки:
     -- 0-ОК, 1-плохая цена, 2-ошибка создания возвр.накладной,
     -- 4 - обнаружена новая строка во вчерашней накладной
     -- 8 - нет данных текущего дня в Config
     -- 16 - ошибка при разбиении накладной на части
  -- Теперь список новых параметров для NC:
  @NewEsfState smallint,      -- статус электронного документа
  @NewOrderDate datetime, 
  @NewOrderDocNumber varchar(100),
  @NewExtra decimal(6,2),     -- наценка
  @NewSrok int,               -- срок оплаты
  @NewSPBuyer decimal(10,2),  -- сумма по данным покупателя
  @NewSTip smallint,          -- тип отгрузки. Если STIP=4, то цены проверять не будем.
  @NewStfNom varchar(30),     -- новый номер счет-фактуры
  @NewStfDate datetime,       -- новая дата счет-фактуры
  @NewMarsh int,              -- 0-перевод в самовывоз
  @NewTomorrow int,           -- 0-сегодня, 1-завтра и т.д.
  @NewArcFlag bit,            -- 1 - пометить как сданную в архив, 0 - не трогать
  @NewSyncReqBySell bit,      -- 1 - создать заявку на приход
  @DisMinExtra bit,           -- 1 - игнорировать несовпадение цены с правилом
  @CheckCommitMode bit,       -- 1 - это режим просмотра электр.документа, тоже игнорировать неправильные цены
  @NewStartDatnom int         -- 0 или целое число, номер исходной накладной для привязки
  -- Прочие входные данные в табл. ParamNV. Если она пустая, то никаких действий с содержимым накладной не будет.
as
declare @Comp varchar(30),@CompSharp varchar(31),@ID int,@Hitag int,@MinP int,@Mpu int,
  @Nds int,@Cost decimal(12,5),
  @Price decimal(14,4),@OrigPrice decimal(14,4),@Sklad int,@Kol int,@kol_b int,@NewKol int,
  @Country varchar(30),@Weight decimal(12,3),@DateR varchar(8),@SrokH varchar(8),
  @Sert_ID int,@Name varchar(100),@Ngrp int,@Gtd varchar(25),@Ispr0 int,@Ispr1 int,@NewLine bit,
  @Ostat int,@MatrPrice decimal(10,2),@Detach bit,@OldPrice decimal(14,4), @OldSP decimal(12,2), @NvID int,
  @minExtra decimal(6,3),@PredZakaz bit,@LMU bit,@DCK int,@minNacen decimal(6,2),
  @EsfPrice decimal(14,4),@EsfKol int,@PLU varchar(16),@Done bit,@FixedPrice bit,@NmHitag int,
  @PriceTip smallint,@nmid int,@LastPrice decimal(15,5),@FlgWeight bit,
  @VitrPrice decimal(12,2),@SourCost decimal(12,5),@SourCost1kg decimal(12,5),
  @Delta decimal(12,3), @ag_id int, @b_id int, @isBack bit, @Fam varchar(100), @OurID smallint,
  @Man_ID int, @BackDatnom int, @NcDCK int,@B_ID2 int, @Stip smallint, @BackError int, @QtyNakl int,@NCEI int,
  @BackReasonID int, @NCID int, @Remark varchar(100), @NewSP decimal(10,2), @NewSC decimal(10,2), @Cmd varchar(1000),
  @PrevDatnomBack int, @BackHitag int, @EffWeight decimal(10,3), @SavedZakaz decimal(10,3), @Actn bit,
  @BackNCID int, @BackID int, @BackPrice decimal(10,2),@BackCost decimal(15,5),@BackSklad int, @BackKol int,
  @KolError int, @Datnom2 int, @ConfigDay datetime, @DatnomOffset int,@StartDatnom int, @NewNCID int,
  @Remarkop varchar(255),@DayShift int, @ND datetime, @TM varchar(8), @gpOur_ID int,
  @Master int, @Worker bit, @BasePrice decimal(15,5), @NvTip tinyint, @Meas tinyint, @DelivCancel bit,
  @UpWeight bit,@DepID smallint, @AddSP decimal(10,2), @LastUsedDatnom int, @NCID2 int, @flgNvZakaz bit,
  @Nzid int,
  @ExiteOrderDate datetime, @ExiteOrderDocNumber varchar(35), @OrderID int, @CountBack int

-- Правило ценообразования: 0-никакого,1-фикс.цена,2-мин.цена,3-запрет
-- ParamNV.PriceTip=(ptNone,  ptConst, ptMin, ptDisab) 

begin
  set @ND=dbo.today();
  set @TM=convert(char(8), getdate(),108);
  set @Comp=Host_name();
  set @CompSharp=@Comp+'#';
  set @ErrCode=0;
  set @Backdatnom=0;
  set @NCID=0;    -- номер записи в журнале NcEdit. 
  set @isBack=0;  -- для начала считаем, что новый возврат еще не появился.
  set @Datnom2=0; -- для начала считаем, что исходная накладная не делилась на части.


  PRINT('CONTROL POINT #0')

  delete from Zakaz where CompName=@CompSharp;
  
  select @Ag_id=ag_id, @b_id=b_id, @Fam=Fam, @OurID=OurID, @Man_ID=man_id, @NcDCK=DCK,
    @B_ID2=B_ID2, @Stip=Stip, @OldSP=SP, @Actn=Actn, @StartDatnom=StartDatnom,
    @gpOur_ID=gpOur_ID
    from nc where datnom=@datnom;

  select @Master=iif(master>0, master, pin), @Worker=Worker from Def where Pin=@B_ID;

  if @Datnom<dbo.fnDatnom(@ND,1) and exists(select * from ParamNV where Comp=@Comp and @NewLine=1) BEGIN
    set @ErrCode=4;
    select @ErrCode as ErrCode,'Обнаружена добивка в старую накладную' as ErrMsg;
    return;
  end;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  BEGIN TRANSACTION ProcessTran; 


  /*********************************************************************************************************
  **          ПОЛНЫЙ ВОЗВРАТ ЛЮБОЙ СЕГОДНЯШНЕЙ НАКЛАДНОЙ, в т.ч. возвратной.                              **
  **          Правила ценообразования и изменения цены игнорируем.                                        **
  **********************************************************************************************************/
  if @flgDrop=1 and dbo.DatNomInDate(@datnom)=@ND
  BEGIN
    declare @TotalKol decimal(10,3), @AlreadyBack bit,@KassID1 int,@KassID2 int, @Refdatnom int, 
      @Plata decimal(15,5), @StartKol decimal(10,3);

    -- Мы грохаем сегодняшнюю возвратную накладную?
    set @TotalKol=(select sum(kol) from nv where datnom=@Datnom);
    set @Refdatnom=(select Refdatnom from nc where datnom=@datnom);
    set @AlreadyBack=iif(@Refdatnom<>0 and @TotalKol<0,1,0);

    set @KassID1=0;
    set @KassID2=0;
    set @Plata=0;

    declare CB CURSOR FAST_FORWARD FOR
      select NvID, ID, Hitag,Cost,OldPrice as Price,Sklad, Kol-Kol_B as StartKol,
        NewKol-(Kol-kol_b) as Delta, -- Здесь обычно @Delta>0
        BackReasonID, ReasonRemark
      FROM dbo.ParamNV 
      where Comp=@Comp and kol<>kol_b and NewLine=0 and flgNVZakaz=0 
    open CB;
    fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @StartKol, @Delta, @BackReasonID, @Remark

    while @@fetch_status=0 BEGIN
      if @NCID=0 begin -- ЗАПИСЬ В ЖУРНАЛ изменений текущей накладной:
        INSERT INTO dbo.NCEdit(Nnak,DatNom,B_ID,BrName,OP,SP,SC,NewSP,NewSC,Mode,
          Extra,Srok,NalogEXST,Nalog,Our_ID,DCK,NewDCK,NewExtra) 
        select dbo.InNnak(@datnom), @Datnom, @B_ID, @Fam, @Op, SP,SC,SP,SC, 1, -- Mode=1?
          Extra, Srok, 0,0, @OurID, @NcDCK, @NcDCK, Extra
          from nc where datnom=@datnom;
        set @NCID=SCOPE_IDENTITY();
      end;
      if @AlreadyBack=1 and @NCID2=0 begin -- запись в журнал изменений исходной накладной:
        INSERT INTO dbo.NCEdit(Nnak,DatNom,B_ID,BrName,OP,SP,SC,NewSP,NewSC,Mode,
          Extra,Srok,NalogEXST,Nalog,Our_ID,DCK,NewDCK,NewExtra) 
        select dbo.InNnak(@refdatnom), @refDatnom, @B_ID, @Fam, @Op, SP,SC,SP,SC, 1, -- Mode=1?
          Extra, Srok, 0,0, @OurID, @NcDCK, @NcDCK, Extra
          from nc where datnom=@refdatnom;
        set @NCID2=SCOPE_IDENTITY();
      end;
      
      -- ЗАПИСЬ В ЖУРНАЛ ПОДРОБНОСТЕЙ:
      INSERT INTO dbo.NVEdit(NCID,Nnak,DatNom,ID,Hitag, Price,Cost,Nalog5,Kol,NewKol,SkladNo,NewPrice,AddOp) 
        values(@NCID, dbo.InNnak(@datnom), @datnom, @ID, @Hitag, @Price, @Cost, @StartKol, @StartKol+@Delta, 0, @Sklad, @Price, @OP);
      -- ЗАПИСЬ В ЖУРНАЛ ВОЗВРАТОВ:
      insert into RemToRtrn(ND,TM,Datnom,SourDatNom,Id,Hitag,Remark,Reason_ID,Note,Tip) -- tip=2 для прогр.продаж 
        values(@ND,dbo.time(), @Datnom, @DatNom,@Id,@Hitag,@Remark,@BackReasonID,'',2)  

      if @AlreadyBack=1 BEGIN
        -- запись в журнал подробностей:
        INSERT INTO dbo.NVEdit(NCID,Nnak,DatNom,ID,Hitag, Price,Cost,Nalog5,Kol,NewKol,SkladNo,NewPrice,AddOp) 
          values(@NCID2, dbo.InNnak(@refdatnom), @refdatnom, @ID, @Hitag, @Price, @Cost, @StartKol, @StartKol+@Delta, 0, @Sklad, @Price, @OP);
      end;

      update NV set Kol_B=0,kol=0 where nvid=@NVID;    -- Коррекция (обнуление) текущей редактируемой накладной.
      update TDVI set Sell=Sell+@Delta where ID=@ID;   -- Коррекция склада.
      if @AlreadyBack=1 begin-- если текущая накладная возвратная, то правим и исходную накладную:
        print('  Коррекция поля KOL_B в исходной накладной '+cast(@Datnom as varchar));
        update NV set Kol_B=kol_b-@Delta where datnom=@Refdatnom and Hitag=@Hitag;
      end;
      fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @StartKol, @Delta, @BackReasonID, @Remark
    end; -- while @@fetch_status=0
    close CB;
    deallocate CB;
    
    if exists(select * from NvZakaz where datnom=@datnom and Done=0 )
       Exec warehouse.operator_cancel_nvzakaz @datnom,0,'',@Op;

    update NC set SP=0, SC=0 where datnom=@datnom;

    if @AlreadyBack=1 BEGIN -- с текущей возвратной накладной связаны две кассовые операции!
      select top 1 @KassID2=kassid, @Plata=abs(plata) from Kassa1 k 
        where nd=dbo.today() and Oper=-2 and Sourdatnom=@Datnom and Plata<0 and Act='ВО' order by kassid desc;
      Print('  Возврат возврата, @Datnom='+Cast(@Datnom as varchar)+', @Refdatnom='+cast(@Refdatnom as varchar)
           +', @Kassid2='+cast(@kassid2 as varchar)+', @Plata='+cast(@plata as varchar));      
      if @KassID2 is not null begin -- вторая из них найдена.
        set @Plata=(select abs(plata) from kassa1 where KassID=@Kassid2);
        print('  Коррекция двух кассовых операций на сумму +- '+cast(@Plata as varchar))
        set @KassId1=(select top 1 kassid from Kassa1 k where nd=dbo.today() and Oper=-2 and Sourdatnom=@Refdatnom and Plata>0 and Act='ВО');
        if @KassId1 is not null begin -- а вот и первая нашлась
          print(  'kassid='+cast(@KassId1 as varchar)+' и kassid='+cast(@kassid2 as varchar))
          update Kassa1 set Plata=0 where KassID=@KassID2;
          update Kassa1 set Plata=Plata-@Plata where KassID=@KassID1;
          update NC set Fact=Fact+@Plata where Datnom=@Datnom;
          update NC set Fact=Fact-@Plata where Datnom=@Refdatnom;
          print('  Возврат возврата выполнен.')
        end;
      end; -- if @KassID2 is not null
    end; -- if @AlreadyBack=1
  end; -- if @flgDrop=1 and dbo.DatNomInDate(@datnom)=@ND


  /*****************************************************************************************************
  **    ПОЛНЫЙ ВОЗВРАТ СТАРОЙ НАКЛАДНОЙ. Правила ценообразования и изменения цены игнорируем.         **
  **    При возврате и продаже эта часть тоже выполняется.                                            **
  ****************************************************************************************************/
  if @flgDrop in (1,2) and dbo.DatNomInDate(@datnom) < @ND 
  BEGIN
    set @LastUsedDatnom=(select top 1 datnom from nc order by datnom desc);
    PRINT('ВХОД В МОДУЛЬ ВОЗВРАТА СТАРОЙ НАКЛАДНОЙ');
    declare CB CURSOR FAST_FORWARD FOR
      select NvID, ID, Hitag,Cost,OldPrice as Price,Sklad, Kol_B-kol as Delta, -- Здесь обычно @Delta<0
        Nds, DCK, Weight, ReasonRemark, BackReasonID
      FROM dbo.ParamNV 
      where Comp=@Comp and kol<>kol_b and NewLine=0 and flgNVZakaz=0
    OPEN CB; 
    fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @Delta, @Nds, @Dck, @EffWeight,@Remark, @BackReasonID
     
    
    set @CountBack = 0 
    while @@fetch_status=0 BEGIN
      set @CountBack = @CountBack + 1  
      -- ЗАПИСЬ В ЖУРНАЛ:
      if @NCID=0 begin
        INSERT INTO dbo.NCEdit(Nnak,DatNom,B_ID,BrName,OP,SP,SC,NewSP,NewSC,Mode,
          Extra,Srok,NalogEXST,Nalog,Our_ID,DCK,NewDCK,NewExtra) 
        select dbo.InNnak(@datnom), @Datnom, @B_ID, @Fam, @Op, SP,SC,SP,SC, 1, -- Mode=1?
          Extra, Srok, 0,0, @OurID, @NcDCK, @NcDCK, Extra
          from nc where datnom=@datnom;
        set @NCID=SCOPE_IDENTITY();
      end;
      -- ЗАПИСЬ В ЖУРНАЛ ПОДРОБНОСТЕЙ:
      INSERT INTO dbo.NVEdit(NCID,Nnak,DatNom,ID,Hitag, Price,Cost,Nalog5,Kol,NewKol,SkladNo,NewPrice,AddOp) 
      values(@NCID, dbo.InNnak(@datnom), @datnom, @ID, @Hitag, @Price, @Cost, -@DELTA, 0, 0, @Sklad, @Price, @OP);
      -- ЗАПИСЬ В ЖУРНАЛ ВОЗВРАТОВ:
      insert into RemToRtrn(ND,TM,Datnom,SourDatNom,Id,Hitag,Remark,Reason_ID,Note,Tip) -- tip=2 для прогр.продаж 
        values(@ND,dbo.time(), null,@DatNom,@Id,@Hitag,@Remark,@BackReasonID,'',2)  
      
      --Для генерации возвратной накладной перепишем строки данных в табл. Zakaz процедурой SaveBackZakaz:
      set @SavedZakaz=0.0;
      /*CREATE procedure dbo.SaveBackZakaz
        @CompName varchar(30), @Hitag INT, @TekID int, @Qty float, 
        @Sklad int=0, @SavedZakaz float=0 out, @Price money=0, @EffWeight float=0, 
        @Nds int=0, @Cost money=0, @MainExtra decimal(7,2)=0,
        @NvID int=0, @RefTekId int=0, @StfNom varchar(17)='', @StfDate datetime=NULL, @DocNom varchar(20)='', @DocDate datetime=NULL,
        @RefDatnom int=0, @DCK int=0*/
      exec dbo.SaveBackZakaz 
        @CompSharp, @Hitag, @ID, @Delta,
        @Sklad, @SavedZakaz, 0.00, @EffWeight, 
        @Nds, 0.00, 0.0, -- Cost и Price процедура вычислит сама, вместо них передаем нули.
        @NvID, @Id, '', NULL,'', NULL,
        @Datnom, @DCK;


      fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @Delta, @Nds, @Dck, @EffWeight,@Remark, @BackReasonID
    end; -- while @@fetch_status=0
    close CB;
    deallocate CB;
    
    if exists(select * from NvZakaz where datnom=@datnom and Done=0)
       Exec warehouse.operator_cancel_nvzakaz @datnom,0,'',@Op;
    
    if @CountBack > 0 begin
    
      print('Подготовка к вызову SaveNakl в модуле возврата старой накладной @Datnom='+cast(@datnom as varchar))
     /* exec dbo.SaveNakl -- эта процедура сама скорректирует склад и исходную накладную:
          @CompSharp, @B_ID, @Fam,
          @OurID, @Ag_ID, @OP,  0, 
          0,  @Man_ID, 0,  null,  0, 
          0, 0, @DatNom, 0, @BackDatNom, 
          0,  '',  null, 
          '', @NcDCK, @B_ID2, 0, 
          0, 0, 0, @KolError, 0,
          @QtyNakl;
     */     
      if @KolError<>0 set @ErrCode=2;    
--      PRINT('Выполнена процедура SaveNakl, код ошибки '
--          +cast(isnull(@KolError,'?') as varchar)+', номер новой возвратной накладной @BackDatnom='
--          +cast(isnull(@BackDatnom,'?') as varchar))
      PRINT('Выполнена процедура SaveNakl, код ошибки '
          +cast(@KolError as varchar)+', номер новой возвратной накладной @BackDatnom='
          +cast(@BackDatnom as varchar))
      update RemToRtrn set Datnom=@BackDatnom where SourDatnom=@Datnom and Datnom is null
      if @KolError<>0 set @ErrCode=2;      
    end    
   
  end;

  /*****************************************************************************************************
  **    Продажа только что возвращенных товаров в режиме возврат+продажа                              **
  **    Ниже новый кусок, возможно, потребуется отладка:                                              **
  *****************************************************************************************************/
  PRINT('КОНТРОЛЬНАЯ ТОЧКА 210 ПРОЙДЕНА, @FlgDrop='+cast(@FlgDrop as varchar)+', '
         +'@Backdatnom='+cast(@Backdatnom as varchar)+' @ErrCode='+cast(@ErrCode as varchar));
  if @flgDrop = 2 and dbo.DatNomInDate(@datnom)<@ND and @ErrCode=0
  BEGIN
    PRINT('ВХОД В МОДУЛЬ ПОВТОРНОЙ ПРОДАЖИ ТОВАРОВ ИЗ ВОЗВРАТНОЙ НАКЛАДНОЙ '+cast(@Backdatnom as varchar));
    -- Готовимся к созданию новой расходной накладной.  
    select @ConfigDay=cast(val as datetime) from Config where Param='DatnomOffset'
    if @ConfigDay<>@ND 
      set @ErrCode=@ErrCode | 8;
    else
    BEGIN -- потребуется новая запись в таблице продаж, пока что со случайным номером:
      declare CB CURSOR FAST_FORWARD FOR
      select NvID, ID, Hitag,Cost,OldPrice as Price,Sklad, Kol-Kol_B as Delta, -- Здесь обычно @Delta<0
        Nds, DCK, Weight, ReasonRemark, BackReasonID, flgNVZakaz
      FROM dbo.ParamNV 
      where Comp=@Comp and kol<>kol_b and NewLine=0 
      
      OPEN CB; 
      fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @Delta, @Nds, @Dck, @EffWeight,@Remark, @BackReasonID, @flgNVZakaz

      while @@fetch_status=0
      BEGIN
        --Для генерации накладной перепишем строки данных в табл. Zakaz процедурой SaveZakaz:
        set @SavedZakaz=0.0;
        
        if isnull(@ID,0) = 0 begin
          set @ID=(select top 1 ID from tdvi where hitag=@hitag and morn-sell+isprav-remov>0 and sklad=@Sklad)
        end
        
        EXEC [dbo].[SaveZakaz]  
            @CompSharp, @Hitag, @ID, @Delta, @Sklad, 
            @SavedZakaz, @Price, @EffWeight, @Nds, 0, 
            0, @NcDCK, @NewStfNom, @NewStfDate, '',
            null, 0, @flgNvZakaz, 0, 0;
            
        fetch next from CB into @NvID, @ID, @Hitag,@Cost,@Price,@Sklad, @Delta, @Nds, @Dck, @EffWeight,@Remark, @BackReasonID, @flgNVZakaz
      END; -- while @@fetch_status=0
      close CB;
      deallocate CB;
      
      print('Подготовка к вызову SaveNakl в модуле возврата старой накладной @Datnom='+cast(@datnom as varchar))
    /*  EXEC dbo.SaveNakl -- эта процедура создаст новую накладную:
            @CompSharp, @B_ID, @Fam,
            @OurID, @Ag_ID, @OP,  0, 
            0,  @Man_ID, 0,  null,  0, 
            0, 0, 0, 0, @Datnom2, 
            0,  '',  null, 
            '', @NcDCK, @B_ID2, 0, 
            0, 0, 0, @KolError, 0,
            @QtyNakl;*/
      PRINT('Выполнена процедура SaveNakl, код ошибки '
            +cast(@KolError as varchar)+', номер новой расходной накладной @Datnom='
            +cast(@Datnom2 as varchar))
      if @@error<>0 set @ErrCode=@Errcode | 64;
    END; 


  /*  А это был старый вариант 

  PRINT('КОНТРОЛЬНАЯ ТОЧКА 210 ПРОЙДЕНА, @FlgDrop='+cast(@FlgDrop as varchar)+', @Backdatnom='+cast(@Backdatnom as varchar)+' @ErrCode='+cast(@ErrCode as varchar));
  if @Backdatnom=0 set @Backdatnom=(select top 1 Datnom from nc where Datnom>@LastUsedDatnom and OP=@Op and B_ID=@B_ID and SP<0 order by datnom desc);
  PRINT('КОНТРОЛЬНАЯ ТОЧКА 211 ПРОЙДЕНА, @FlgDrop='+cast(@FlgDrop as varchar)+', @Backdatnom='+cast(@Backdatnom as varchar)+' @ErrCode='+cast(@ErrCode as varchar));
  if @flgDrop=2 and dbo.DatNomInDate(@datnom)<@ND and @BackDatnom>0 and @ErrCode=0 BEGIN
    PRINT('ВХОД В МОДУЛЬ ПОВТОРНОЙ ПРОДАЖИ ТОВАРОВ ИЗ ВОЗВРАТНОЙ НАКЛАДНОЙ '+cast(@Backdatnom as varchar));
    -- Готовимся к созданию новой расходной накладной. Какое смещение нумерации сегодня?  
    select @ConfigDay=cast(val as datetime),  @DatnomOffset=cast(Comment as int) from Config where Param='DatnomOffset'
    if @ConfigDay<>@ND 
      set @ErrCode=@ErrCode | 8;
    else BEGIN -- потребуется новая запись в таблице продаж, пока что со случайным номером:
      set @Datnom2=round(10000+90000*RAND(),0)+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
      insert into NC (ND,datnom,StartDatnom,B_ID,Fam,Tm,OP,SP,SC,
        Extra,Srok,OurID,Pko,Man_ID, 
        BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
        Remark,Printed,Marsh,BoxQty,WEIGHT1,Actn,CK,Tara,
        RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,
        Comp, Sk50present, DCK, B_ID2, NeedDover, DoverM2, DocNom, DocDate, STip, gpOur_ID, mhid)
      select @ND, @Datnom2, StartDatnom, B_ID,Fam,@TM,@OP,-SP, -SC,
        Extra,Srok,OurID, 0, Man_ID, 
        0,0,0,@ag_id,@newstfnom,@newstfdate,@newtomorrow,0,
        Remark,0,@NewMarsh,0,0,Actn,0,0,
        0,0,0, 0, 0.0, remarkop,
        DayShift, host_name(), 0, DCK, B_ID2, NeedDover, DoverM2, DocNom, DocDate, Stip, gpOur_ID, mhid
      from nc where Datnom=@Backdatnom;
      if @@Error<>0 set @ErrCode = 32; 
      if @ErrCode=0 begin
        set @NewNCID = scope_identity();
        set @Datnom2=@NewNCID+@DatnomOffset; -- настоящий номер новой расходной накладной.
        update NC set Datnom=@Datnom2 where ncid=@NewNCID;
        INSERT INTO NV(DatNom,TekID,Hitag,Price,Cost,Kol,Kol_B,Sklad,BasePrice,Remark,tip,Meas,DelivCancel,OrigPrice,ag_id) 
          select @DatNom2,TekID,Hitag,Price,Cost,-Kol,0,Sklad,BasePrice,Remark,tip,Meas,DelivCancel,OrigPrice,ag_id
          from NV where Datnom=@Backdatnom;
        -- Вычисление флага DONE для новой накладной при необходимости:
        if @Done=0 and @Actn=1 set @Done=1;
        if @Done=0 begin
          if @Master>0 and exists(select * from DefExclude where ExcludeType=1 and Pin=@Master) 
            set @Done=1;
          else begin
            set @DepID=(select depid from Agentlist where ag_id=@ag_id);
            set @AddSP=ISNULL((select sum(zakaz*price) from nvzakaz where datnom=@Datnom and Done=0),0);
            if @NewSP+@AddSP>=1500 or @NewSP<0 or @DepID=3 or @DepID=26 or @DepID=43 or @worker=1 set @Done=1;
          end;
        end;  
        update NC set Done=@Done where Datnom=@Datnom2;
        print('Подготовка к массовой коррекции TDVI.SELL ...');
        update tdVi
          set Sell=Sell+nv.kol
          from tdvi inner join nv on nv.tekid=tdvi.ID
          where nv.datnom=@Datnom2;
        print('Массовая коррекция TDVI.SELL выполнена, код ошибки '+cast(@@error as varchar));
        if @@error<>0 set @ErrCode=@Errcode | 64;
      end; -- if @ErrCode=0
    end; -- нет ошибок, две записи в NC созданы.
    if @Datnom2>0 exec RecalcNCSumm @Datnom2;
*/    
    -- Возможно, исходная накладная включена в систему электронных заявок?
    -- Тогда в этой системе нужно поменять ее номер на новую расходную:
    if @Datnom2>0 and exists(select * from NC_ExiteInfo where Datnom=@Datnom) 
    BEGIN
      select top 1 @OrderID=OrderID from NC_ExiteInfo where Datnom=@Datnom;
      update NC_ExiteInfo set Datnom=@Datnom2 where datnom=@Datnom;
      update exite_orders set Status=2 where ID=@OrderID;      
    END;
END; -- Конец модуля "Возврат+продажа".



  /*********************************************************************
  **          КОРРЕКЦИЯ ЦЕН, ВОЗВРАТ ТОВАРОВ, ДОБИВКА В НАКЛАДНОЙ     **
  *********************************************************************/
  else if @flgDrop=0 and @flgEdit=1 begin
    PRINT('CONTROL POINT #1')
    -- Проверим новые цены при необходимости:
    if @CheckCommitMode=0 and @DisMinExtra=0 and @Stip<>4 and @flgDrop=0 and @OldSP<0
    and exists( -- Правило ценообразования: 0-никакого,1-фикс.цена,2-мин.цена,3-запрет
      select * from ParamNV where Comp=@Comp 
        and  ( (PriceTip=1 and abs(Price-MatrPrice)>=0.01) -- MatrPrice-цена из GenerPriceNsp2b
          or (PriceTip=2 and Price<MatrPrice)
          or (PriceTip=3)
          ))
    BEGIN
      set @ErrCode=1;
      select @ErrCode as ErrCode,'Обнаружена неправильная цена' as ErrMsg;
      return;
    end;

    -- Если это дегустация, то цены править нельзя:
    if exists(select dck from DefContract where dck=@DCK and Degust>0)
    and exists(select * from paramnv where comp=@Comp and price<>OldPrice) BEGIN
      set @ErrCode=1;
      select @ErrCode as ErrCode,'Цены не подлежат редактированию (дегустация)' as ErrMsg;
      return;
    end;


    declare c1 cursor fast_forward for
    SELECT 
      ID,Hitag,MinP,Mpu,Nds,Cost,Price,OrigPrice,Sklad,Kol,kol_b,NewKol,Country,Weight,DateR,SrokH,
      Sert_ID,Name,Ngrp,Gtd,Ispr0,Ispr1,NewLine,Ostat,MatrPrice,Detach,OldPrice,NvID,minExtra,PredZakaz,LMU,
      DCK,minNacen,EsfPrice,EsfKol,PLU,Done,FixedPrice,NmHitag,PriceTip,nmid,LastPrice,FlgWeight,VitrPrice,
      SourCost,SourCost1kg,flgNvZakaz,Nzid,ReasonRemark,BackReasonID
    FROM dbo.ParamNV 
    where Comp=@Comp and (price<>oldprice OR newkol<>kol-kol_b) -- исключено 24.01.18: and NewLine=0 
    order by ID;

    open c1;
    fetch next from c1 INTO @ID,@Hitag,@MinP,@Mpu,@Nds,@Cost,@Price,@OrigPrice,@Sklad,@Kol,@kol_b,
      @NewKol,@Country,@Weight,@DateR,@SrokH,@Sert_ID,@Name,@Ngrp,@Gtd,@Ispr0,@Ispr1,@NewLine,@Ostat,
      @MatrPrice,@Detach,@OldPrice,@NvID,@minExtra,@PredZakaz,@LMU,@DCK,@minNacen,@EsfPrice,@EsfKol,@PLU,
      @Done,@FixedPrice,@NmHitag,@PriceTip,@nmid,@LastPrice,@FlgWeight,@VitrPrice,@SourCost,@SourCost1kg,
      @flgNvZakaz, @Nzid,@Remark,@BackReasonID
    while @@fetch_status=0 BEGIN
      PRINT('CONTROL POINT #2, ID='+cast(@ID as varchar))
      set @delta=@NewKol-(@Kol-@Kol_b) -- обычно это возврат, @Delta<=0;

      -- ЗАПИСЬ В ЖУРНАЛ:
      if @NCID=0 begin
        INSERT INTO dbo.NCEdit(Nnak,DatNom,B_ID,BrName,OP,SP,SC,NewSP,NewSC,Mode,
          Extra,Srok,NalogEXST,Nalog,Our_ID,DCK,NewDCK,NewExtra) 
        select dbo.InNnak(@datnom), @Datnom, @B_ID, @Fam, @Op, SP,SC,SP,SC, 1, -- Mode=1?
          Extra, Srok, 0,0, @OurID, @NcDCK, @NcDCK, Extra
          from nc where datnom=@datnom;
        set @NCID=SCOPE_IDENTITY();
      end;

      -- ЗАПИСЬ В ЖУРНАЛ ПОДРОБНОСТЕЙ:
      INSERT INTO dbo.NVEdit(NCID,Nnak,DatNom,ID,Hitag,
        Price,Cost,Nalog5,Kol,NewKol,SkladNo,NewPrice,AddOp) 
      values(@NCID, dbo.InNnak(@datnom), @datnom, iif(@flgNvZakaz=1,-1,@ID), @Hitag,
        @OldPrice, @Cost, 0, @Kol-@Kol_B, @NewKol, @Sklad, @Price, @OP);
      
      --if @kol_b<>0 для весового товара проверку сделать через nv_join begin

      -- ИЗМЕНЕНИЕ ЦЕНЫ :
      if @Price<>@OldPrice and @NewLine=0 and @flgNvZakaz=0 begin -- только старые строки
        PRINT('CONTROL POINT #3');
        update NV set price=@Price where NVID=@NvID;
        print (cast(@Datnom as varchar)+'  id:'+CAST(@id as varchar))
        declare @DatnomBack int, @nvidBack int


       --****************************************ИСПРАВЛЕНИЕ СВЯЗАННЫХ НАКЛАДНЫХ**************************************************
        declare crBack cursor fast_forward for
          select c.datnom, v.nvid, v.tekid as BackID, v.Price as BackPrice, v.cost as BackCost,
            v.Sklad as BackSklad, V.Kol as BackKol, v.Hitag as BackHitag
          from nc c left join nv v on c.datnom=v.datnom 
          where c.refdatnom=@datnom and 
               (v.tekid=@id or v.tekid=(select nj.tekid from  nv_join nj where nj.datnom=c.datnom and nj.reftekid=@id))

        open crBack;
        fetch next from crBack into @DatnomBack, @nvidBack, @BackID, @BackPrice,@BackCost,@BackSklad,@BackKol,@BackHitag
      
        DECLARE @CNT INT;
        set @CNT=1000; -- страховка от зацикливания.
        
        while @CNT>0 and @@FETCH_STATUS=0  begin
          set @PrevDatnomBack=@Datnomback
          -- потребуется новая запись в журнале изменений.
          INSERT INTO dbo.NCEdit(Nnak,DatNom,B_ID,BrName,OP,SP,SC,NewSP,NewSC,Mode,
            Extra,Srok,NalogEXST,Nalog,Our_ID,DCK,NewDCK,NewExtra) 
          select dbo.InNnak(@Datnomback), @Datnomback, B_ID, Fam, @Op, SP,SC,SP,SC, 1, -- Mode=1?
            Extra, Srok, 0,0, nc.ourID, DCK, DCK, Extra
            from nc where datnom=@Datnomback;
          set @BackNCID=SCOPE_IDENTITY();

          while @@FETCH_STATUS=0 and @PrevDatnomBack=@Datnomback begin
            print('   Коррекция цены и суммы в связанной накладной '+cast(@DatnomBack as varchar)+', CNT='+caST(@CNT AS VARCHAR))
            update NV set Price=@Price where nvid=@NvidBack;

            INSERT INTO dbo.NVEdit(NCID,Nnak,DatNom,ID,Hitag, Price,Cost,Nalog5,Kol,NewKol,SkladNo,NewPrice,AddOp) 
            values(@BackNCID, dbo.InNnak(@DatnomBack), @DatnomBack, @BackID, @BackHitag, @BackPrice, @BackCost, 
              0, @BackKol, @BackKol, @BackSklad, @Price, @OP);
                  
            print('   NvidBack='+CAST(@nvidBack as varchar));
            fetch next from crBack into @DatnomBack, @nvidBack, @BackID, @BackPrice,@BackCost,@BackSklad,@BackKol,@BackHitag
            set @CNT=@CNT-1;
          end;
          exec RecalcNCSumm @PrevDatnomBack;
          update NcEdit set NewSP=(select SP from Nc where datnom=@PrevDatnomBack) where ncid=@BackNCID;
          set @CNT=@CNT-1;
        end    
        close crBack;
        deallocate crBack;
      --***********************************************************************************************************************  
        
      end --// ИЗМЕНЕНИЕ ЦЕНЫ :

      -- При коррекции кол-ва тоже кое-что правим:
      if @Delta<>0 begin
        PRINT('CONTROL POINT #4');
        print ('Datnom='+cast(@Datnom as varchar)+',  id='+CAST(@id as varchar)+',  Delta='+cast(@Delta as varchar)
          +', @NewLine='+cast(@Newline as varchar)+', @FlgNvZakaz='+cast(@FlgNvZakaz as varchar)
          +', @NzId='+cast(@NzId as varchar)+', @Done='+cast(@Done as varchar));
        if @ND = dbo.DatNomInDate(@datnom) begin 
          if @NewLine=1 and @flgNvZakaz=0 begin -- новая строка в NV
            update TDVI set Sell=Sell+@Delta where ID=@ID;
            INSERT INTO NV(DatNom,TekID,Hitag,Price,Cost,Kol,Kol_B,
              Sklad,BasePrice,Remark,tip,Meas,DelivCancel,OrigPrice,ag_id) 
            VALUES (@DatNom,@ID,@Hitag,@Price,@Cost,@Delta,0,
              @Sklad,@Price,null,0,2,0,null,@ag_id);
          end;
          else if @NewLine=1 and @flgNvZakaz=1 and @Delta>0 begin -- новая строка в NvZakaz
            INSERT INTO nvZakaz(datnom,Hitag,Zakaz,Done,ND,Price,Cost,comp,tm,tmEnd,
              curWeight,tekWeight, dt,dtEnd,ID,Remark,skladNo,OP,spk,AuthorOP,NewDatnom,group_id) 
            values(@Datnom,@Hitag,@Delta,0,@ND,@Price,@Cost,@Comp+'_x', @TM,null,
              null,null,@ND,null,null,'',@Sklad,@op,0,@op,null,0)
          end;
          else if @NewLine=0 and @flgNvZakaz=0 BEGIN -- коррекция количества в существующей строке:
            update NV set kol=kol+@Delta where nvid=@Nvid;
            update tdvi set sell=sell+@delta where id=@ID;

            if @Delta<0 insert into RemToRtrn(ND,TM,Datnom,SourDatNom,Id,Hitag,Remark,Reason_ID,Note,Tip) -- tip=2 для прогр.продаж 
            values(@ND,dbo.time(), @DatNom, @DatNom,@Id,@Hitag, @Remark,@BackReasonID,'',2)  

          end;
          else if @NewLine=0 and @flgNvZakaz=1 and @Delta<0 and @Nzid>0 and @Done=0 begin -- обнуление количества в существующей строке:
            Print('обнуление количества в существующей строке NZID='+cast(@nzid as varchar));
            Exec warehouse.operator_cancel_nvzakaz @datnom,@nzid,'',@Op;
          end;
        end
        else begin -- вчера и раньше - потребуется возвратная накладная:
          set @isBack=1;

          --Для генерации возвратной накладной перепишем строки данных в табл. Zakaz процедурой SaveBackZakaz:
          set @SavedZakaz=0.0;
          exec dbo.SaveBackZakaz 
            @CompSharp, @Hitag, @ID, @Delta,
            @Sklad, @SavedZakaz, 0.00, @EffWeight, 
            @Nds, 0.00, 0.0, -- Cost и Price процедура вычислит сама, вместо них передаем нули.
            @NvID, @Id, '', NULL,'', NULL,
            @Datnom, @DCK;

          insert into RemToRtrn(ND,TM,Datnom,SourDatNom,Id,Hitag,Remark,Reason_ID,Note,Tip) -- tip=2 для прогр.продаж 
          values(@ND,dbo.time(), null,@DatNom,@Id,@Hitag, @Remark,@BackReasonID,'',2)  
        end
      end;
      fetch next from c1 INTO @ID,@Hitag,@MinP,@Mpu,@Nds,@Cost,@Price,@OrigPrice,@Sklad,@Kol,@kol_b,
        @NewKol,@Country,@Weight,@DateR,@SrokH,@Sert_ID,@Name,@Ngrp,@Gtd,@Ispr0,@Ispr1,@NewLine,@Ostat,
        @MatrPrice,@Detach,@OldPrice,@NvID,@minExtra,@PredZakaz,@LMU,@DCK,@minNacen,@EsfPrice,@EsfKol,@PLU,
        @Done,@FixedPrice,@NmHitag,@PriceTip,@nmid,@LastPrice,@FlgWeight,@VitrPrice,@SourCost,@SourCost1kg,
        @flgNvZakaz, @Nzid,@Remark,@BackReasonID
    end;
    close c1;
    deallocate c1;
    
    
    if @isBack=1 begin -- должна появиться новая возвратная накладная?
      PRINT('CONTROL POINT #6');
      set @BackError=0;
      set @QtyNakl=0;
      EXEC [dbo].[SaveNakl]  @CompSharp, @B_ID, @Fam, @OurID, @Ag_ID, @OP, 1, 0, @Man_ID, 0, '', 0, 0,
        0, @DatNom, 0, @BackDatNom, 0, '', null, '', @NcDCK, @B_ID2,
        0, @Stip, 0, 0, @BackError, 0, @QtyNakl;
        
      if @BackError=0 update RemToRtrn set Datnom=@BackDatnom where SourDatnom=@Datnom and Datnom is null 
      else set @ErrCode=@Errcode | 2;
  
    end;


    /****************************************************************************
    **    МОЖЕТ БЫТЬ, КАКИЕ-ТО СТРОКИ НУЖНО ОТДЕЛИТЬ В ДРУГУЮ НАКЛАДНУЮ?       **
    ****************************************************************************/
    declare c2 cursor fast_forward for 
    SELECT NVID 
      ID,Hitag,MinP,Mpu,Nds,Cost,Price,OrigPrice,Sklad,Kol,kol_b,NewKol,Country,Weight,DateR,SrokH,
      Sert_ID,Name,Ngrp,Gtd,Ispr0,Ispr1,NewLine,Ostat,MatrPrice,Detach,OldPrice,NvID,minExtra,PredZakaz,LMU,
      DCK,minNacen,EsfPrice,EsfKol,PLU,Done,FixedPrice,NmHitag,PriceTip,nmid,LastPrice,FlgWeight,VitrPrice,
      SourCost,SourCost1kg
    FROM dbo.ParamNV 
    where Comp=@Comp and newkol>0 and Detach=1 and @Datnom>=dbo.fnDatnom(@ND,1)
    order by ID;
    
    open c2;
    fetch next from c2 INTO @ID,@Hitag,@MinP,@Mpu,@Nds,@Cost,@Price,@OrigPrice,@Sklad,@Kol,@kol_b,
      @NewKol,@Country,@Weight,@DateR,@SrokH,@Sert_ID,@Name,@Ngrp,@Gtd,@Ispr0,@Ispr1,@NewLine,@Ostat,
      @MatrPrice,@Detach,@OldPrice,@NvID,@minExtra,@PredZakaz,@LMU,@DCK,@minNacen,@EsfPrice,@EsfKol,@PLU,
      @Done,@FixedPrice,@NmHitag,@PriceTip,@nmid,@LastPrice,@FlgWeight,@VitrPrice,@SourCost,@SourCost1kg

    if @@fetch_status=0 BEGIN -- что-то найдено, потребуется новая расходная накладная.
      -- Какое смещение нумерации сегодня?  
      select @ConfigDay=cast(val as datetime),  @DatnomOffset=cast(Comment as int) from Config where Param='DatnomOffset'
      if @ConfigDay<>@ND 
        set @ErrCode=@ErrCode | 8;
      else BEGIN -- потребуется новая запись в таблице продаж, пока что со случайным номером:

        set @datnom2=round(10000+90000*RAND(),0)+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));
        
        insert into NC (ND,datnom,StartDatnom,B_ID,Fam,Tm,OP,SP,SC,
          Extra,Srok,OurID,Pko,Man_ID, 
          BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
          Remark,Printed,Marsh,BoxQty,WEIGHT1,Actn,CK,Tara,
          RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,
          Comp, Sk50present, DCK, B_ID2, NeedDover, DoverM2, DocNom, DocDate, STip, gpOur_ID, mhid)
        select @ND, @datnom2, StartDatnom, B_ID,Fam,convert(char(8), getdate(),108),@OP,0.0, 0.0,
          @NewExtra, @NewSrok, @OurID, 0, @Man_ID, 
          0,0,0,@Ag_id,@newstfnom,@newstfdate,tomorrow,0,
          Remark,0,@NewMarsh,0,0,Actn,0,0,
          0,0,0, 0, 0.0, remarkop,
          DayShift, host_name(), 0, DCK, B_ID2, NeedDover, DoverM2, DocNom, DocDate, Stip, gpOur_ID, mhid
        from nc where Datnom=@Datnom;

        if @@Error<>0 set @ErrCode = 16; 

        if @ErrCode=0 begin
          set @NewNCID = scope_identity();
          set @Datnom2=@NewNCID+@DatnomOffset; -- @Datnom2 - настоящий номер новой накладной, отделенной от исходной.
          update NC set Datnom=@Datnom2 where ncid=@NewNCID;
        end;
      end;
    end;
    -- Перебрасываем записи в новую накладную:
    while @ErrCode=0 and @@fetch_status=0 BEGIN
      PRINT('CONTROL POINT #5, переброс строки из исходной накладной '+cast(@DAtnom as varchar)+'в новую '+cast(@DAtnom2 as varchar)+', NVID='+cast(@NVID as varchar))
      update NV set Datnom=@Datnom2 where nvid=@NVID;
      fetch next from c2 INTO @ID,@Hitag,@MinP,@Mpu,@Nds,@Cost,@Price,@OrigPrice,@Sklad,@Kol,@kol_b,
        @NewKol,@Country,@Weight,@DateR,@SrokH,@Sert_ID,@Name,@Ngrp,@Gtd,@Ispr0,@Ispr1,@NewLine,@Ostat,
        @MatrPrice,@Detach,@OldPrice,@NvID,@minExtra,@PredZakaz,@LMU,@DCK,@minNacen,@EsfPrice,@EsfKol,@PLU,
        @Done,@FixedPrice,@NmHitag,@PriceTip,@nmid,@LastPrice,@FlgWeight,@VitrPrice,@SourCost,@SourCost1kg
    end;
    close C2;
    deallocate c2;
  end; -- if @flgEdit = 1

  

  set @Cmd='update NC set Extra='+cast(@NewExtra as varchar)+', Srok='+Cast(@NewSrok as varchar);  
  if @NewEsfState is not null set @Cmd=@Cmd+', State='+cast(@NewEsfState as varchar(2));
  if @NewSTip is not null set @Cmd=@Cmd+', Stip='+cast(@NewSTip as varchar(3))
  if @NewStfNom is not null set @Cmd=@Cmd+', StfNom='''+@NewStfNom+'''';
  if @NewStfDate is not null  set @Cmd=@Cmd+', StfDate='''+convert(varchar, @NewStfDate, 104)+'''';
  if @NewMarsh is not null set @Cmd=@Cmd+', Marsh='+cast(@NewMarsh as varchar); -- ЗДЕСЬ, ВИКТОР! НАДО БУДЕТ И ПОЛЕ MHID СКОРРЕКТИРОВАТЬ!
  if @NewTomorrow is not null set @Cmd=@Cmd+', Tomorrow='+cast(@NewTomorrow as varchar);

  if isnull(@NewStartDatnom,0)=0 or isnull(@NewStartDatnom,0)=@Datnom 
    set @Cmd=@Cmd+', StartDatnom='+cast(@datnom as varchar)+', Refdatnom=0';
  else
    set @Cmd=@Cmd+', StartDatnom='+cast(isnull(@NewStartDatnom,0) as varchar)+', RefDatnom='+cast(isnull(@NewStartDatnom,0) as varchar);

  -- ЗДЕСЬ, ВИКТОР! Насчет ArcFlag еще надо подумать.
  if isnull(@NewArcFlag,0)=1 set @Cmd=@cmd+', Ready=1';

  -- if isnull(@NewSyncReqBySell,0)=1 -- ЗДЕСЬ, ВИКТОР! Нужно будет создать заявку на приход.
  
  set @Cmd=@Cmd+' where Datnom='+cast(@datnom as varchar);


  PRINT('CONTROL POINT #7');
  print('Текст команды: '+@Cmd);
  exec (@cmd);

  -- Здесь надо будет записать скорректированные суммы по исходной накладной в NCEDIT.
  if @ErrCode=0 begin
    PRINT('CONTROL POINT #8, запись в NCEDIT, NCID='+cast(@NCID as varchar));
    if @BackDatnom>0 exec dbo.RecalcNCSumm @Backdatnom;
    exec dbo.RecalcNCSumm @datnom;
    select @NewSP=SP, @NewSC=SC from NC where Datnom=@Datnom;
    PRINT('   NewSP='+cast(@NewSP as varchar)+', NewSC='+cast(@NewSC as varchar));
    update NcEdit set NewSP=@NewSP, NewSC=@NewSC where NCID=@NCID;
    if @Datnom2>0 exec dbo.RecalcNCSumm @datnom2;
  
    -- Может быть, нужно обновить данные в NC_ExiteInfo:
    PRINT('CONTROL POINT #9');
    if exists(select * from NC_ExiteInfo where Datnom=@Datnom) 
      update NC_ExiteInfo 
      set OrderDate=@NewOrderDate, OrderDocNumber=@NewOrderDocNumber, SP_Buyer=isnull(@NewSPBuyer,0)
      where Datnom=@Datnom;    
    else if @NewOrderDate is not null or isnull(@NewOrderDocNumber,'') <> ''
      insert into NC_ExiteInfo(Datnom,OrderDate,OrderDocnumber,SP_Buyer) values (@Datnom, @NewOrderDate, @NewOrderDocNumber, isnull(@NewSPBuyer,0));

    -- TODO:
    -- Может, еще что-то...
  end;


  PRINT('CONTROL POINT #10');
  if @ErrCode=0 COMMIT else rollback;

  select @ErrCode as ErrCode, 
  case 
    when @errCode=0 then ''
    when @ErrCode=1 then 'Обнаружена неправильная цена'
    when @ErrCode=2 then 'Ошибка при создании возвратной накладной'
    when @ErrCode=4 then 'Обнаружена добивка в старую накладную'
    else '???'
  end as ErrMsg; 
end