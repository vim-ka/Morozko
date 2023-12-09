

CREATE procedure PrihodRSave_DEL (@PrihodRid int, @OperatorD int) 
as

declare @NewNcom int 
declare @Our_ID smallint
declare @Ncod int
declare @ND datetime
declare @Srok int
declare @op int

declare @TekID int
declare @hitag int
declare @price decimal(19,4)
declare @cost decimal(19,4)
declare @kol int
declare @sert_id int 
declare @minp int
declare @mpu int
declare @dater datetime
declare @srokh datetime
declare @Country int
declare @ProducerName varchar(15)
declare @sklad smallint
declare @Locked bit 
declare @Lock int 
declare @NDS tinyint
declare @Producer int
declare @MeasID tinyint
declare @Netto decimal(12,3)
declare @Brutto decimal(12,3)
declare @WEIGHT decimal(12,3)
declare @Gtd varchar(30)
declare @PrihodRDetKolStr varchar(10)
declare @StrDateR varchar(20)
declare @StrSrokh varchar(20)
declare @OnlyBox bit
declare @DefContr int
declare @flgWeight bit
declare @PinOwner int
declare @DCKOwner int
declare @flgDoopr smallint
declare @NDVend datetime
declare @SafeCust bit
declare @SummaPrice decimal(19,4)
declare @SummaCost decimal(19,4)

begin
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  begin transaction 
	
  select @PinOwner=PrihodRPinOwner, @DCKOwner=PrihodRDCKOwner
  from PrihodReq
  where PrihodRID=@PrihodRid
  
  set @flgDoopr=0;
  set @ND=CONVERT(varchar,getdate(),4);
  set @Our_ID=(select d.our_id from DefContract d left join PrihodReq p on d.DCK=p.PrihodRDefContract where p.PrihodRID=@PrihodRid);  
  set @Ncod=(select PrihodRVendersID from PrihodReq where PrihodRID=@PrihodRid);
  set @OP=(select PrihodROperatorID from PrihodReq where PrihodRID=@PrihodRid);
  set @SafeCust=(select PrihodRDefSafeCust from PrihodReq where PrihodRID=@PrihodRid);
  set @DefContr=(select PrihodRDefContract from PrihodReq where PrihodRID=@PrihodRid);
  set @Srok=(Select srok from DefContract d left join PrihodReq p on d.DCK=p.PrihodRDefContract where p.PrihodRID=@PrihodRid);
  -- если мы дооприходуем то ищем наш common 
  set @NewNcom=(select top 1 PrihodRDetNCom from PrihodReqDet  where PrihodRID=@PrihodRid and PrihodRDetIsSave=1)
  -- иначе новый номер комиссии
  if @NewNcom is Null
   begin 
   	set @NewNcom=(select IsNull(max(Ncom),0)+1 from Comman); 
    -- Заголовок:
    insert into Comman (	Ncom,
    											Ncod,
                          [date],
                          [Time],
      										summaprice,
                          summacost,
                          [ostat],
                          realiz,
                          corr,
                          plata,
                          closdate,
      										srok,
                          op,
                          our_id,
                          doc_nom,
                          doc_date,
      										comp,
                          izmensc,
                          errflag,
                          copyexists,
                          origdate,
      										DCK,
                          TN_nom,
                          TN_date,
                          OrdersID,
                          SafeCust, 
                          PinOwner, 
                          DCKOwner, 
                          PIN)
    select 								@NewNcom as Ncom,
    											PrihodRVendersID,
                          @nd as [date], 
                          CONVERT(varchar,getdate(),8) as [time],
      										1,
                          1, 
                          PrihodRSumCost as Ostat,
                          0 as realiz,
                          0 as corr, 
                          0 as plata, 
                          null as closdate,
      										@srok,
                          PrihodROperatorID,
                          PrihodROurID,
                          PrihodRDocNum,
                          PrihodRDocDate,
      										PrihodRComp, 
                          0,
                          0,
                          0,
                          null,
      										PrihodRDefContract,
                          PrihodRTNNum,
                          PrihodRTNDate,
                          PrihodROrdersID,
                          @SafeCust, 
                          PrihodRPinOwner, 
                          PrihodRDCKOwner, 
                          (select pin from def where ncod=@Ncod)
    from PrihodReq
    where PrihodRID=@PrihodRid; 
   end;
  else 
  begin
  	set @OP=@OperatorD;
    set @flgDoopr=0; --в случае дооприх запоминаем текущего оператора
  end;
  
  -- Табличная часть:
  declare CurDet cursor fast_forward for  
  select 	PrihodRDetHitag,
  				PrihodRDetPrice,
          PrihodRDetCost,
    			sert_id,
          minp,
          mpu,
          PrihodRDetDate,
          PrihodRDetSrokh,
    			LastCountryID,
          PrihodRDetSkladID,
          PrihodRDetLocked,   
    			nds,
          LastProducerID,
          MeasID,
          Netto,
          Brutto,
    			flgWeight,
          PrihodRDetGtd,
          s.OnlyMinP,
          ltrim(RTRIM(p.PrihodRDetKolStr)),
          pr.ProducerName
    from PrihodReqDet p
    join nomen n on n.hitag=p.PrihodRDethitag
    left join SkladList s on s.SkladNo=p.PrihodRDetSkladID
    left join Producer pr on pr.ProducerID=n.LastProducerID
    where PrihodRID=@PrihodRid
    and p.PrihodRDetIsSave=@flgDoopr;
    
  open CurDet; 
  fetch next from CurDet into  @hitag, @price, @cost, @sert_id, @minp,@mpu,
    @dater,@srokh,@Country,@sklad, @Locked,  @NDS, @Producer,@MeasID,
    @Netto,@Brutto,@flgWeight, @Gtd, @OnlyBox,@PrihodRDetKolStr,@ProducerName
  
  -- основной цикл по детализации прихода
  WHILE (@@FETCH_STATUS=0)  BEGIN
    --преобразуем количество @PrihodRDetKolStr и галочку @flgWeight в количество и вес 
    if @flgWeight=1 
    begin
        set @Kol=1;
        set @PrihodRDetKolStr=REPLACE(@PrihodRDetKolStr,',','.');
        WHILE @PrihodRDetKolStr LIKE '%[^.,^0-9]%' SET @PrihodRDetKolStr=STUFF(@PrihodRDetKolStr,PATINDEX('%[^.,^0-9]%',@PrihodRDetKolStr),1,'');   
        set @Weight=CAST(@PrihodRDetKolStr as decimal(12,3));
        set @price=@price*@Weight;
        set @cost=@cost*@Weight;
    end; 
    else 
    begin
		WHILE @PrihodRDetKolStr LIKE '%[^+,^0-9]%' SET @PrihodRDetKolStr=STUFF(@PrihodRDetKolStr,PATINDEX('%[^+,^0-9]%',@PrihodRDetKolStr),1,'');
        if CharIndex('+', @PrihodRDetKolStr)=0   set @Kol=@minp*Cast(@PrihodRDetKolStr AS INT)
        else SET  @Kol=Cast(Left(@PrihodRDetKolStr, CharIndex('+', @PrihodRDetKolStr) - 1) AS INT)*@minp+Cast(Reverse(Left(Reverse(@PrihodRDetKolStr), CharIndex('+', Reverse(@PrihodRDetKolStr)) - 1)) AS INT);
        set @Weight=0;
    end;
    select @Kol,@Weight;
    
    -- дата изготовления и срок хранения
    if @dater is null or @Dater<'20000101' 
      begin
        set @dater=null;
        set @StrDateR=null;
      end; 
    else 
    	set @StrDater=CONVERT(varchar,@dater,4);
 
    if @srokh is null or @srokh<'20000101' 
      begin
        set @srokh=null;
        set @Strsrokh=null;
      end; 
    else 
    	set @Strsrokh=CONVERT(varchar,@srokh,4);
    
    -- если не тара и не исключения типа справок и поддонов, то блокируем
    set @Lock=(select 0 from taracode2 t where t.TaraTag=@hitag group by t.TaraTag);
    if @hitag in (5659,2296,90858,95007,15028) set @Lock=0;
    
    if @Lock is null set @Lock=2;
   
    -- в tdvi новый ID товара
    set @TekID=(select IsNull(max(ID),0)+1 from TDVI);
    
    -- Запись в склад:
    insert into tdVI(	ND, 
    									ID,
                      StartID,
                      Ncom,
                      Ncod,
                      DatePost,
      								Price,
                      Start,
                      StartThis,
                      Hitag,
                      Sklad,
                      Cost,
                      Nalog5,
                      MinP,
                      Mpu,
                      Sert_ID,
      								Morn,
                      Sell,
                      Isprav,
                      REMOV,
                      Bad,
                      DateR,
                      Srokh,
                      CountryID,
      								Rezerv,
                      Locked,
                      ProducerID,
                      Gtd,
                      Vitr,
                      Our_ID,
                      WEIGHT,
      								SaveDate,
                      MeasID,
                      OnlyMinP,
                      DCK,
                      SafeCust,
                      Country,
                      LockID, 
                      PinOwner, 
                      DCKOwner,
                      PIN)
	values(							@ND, 
  										@TekID,
                      @TekID,
                      @NewNcom,
                      @Ncod,
                      @ND,
      								@Price,
                      @Kol,
                      @Kol,
                      @Hitag,
                      @Sklad,
                      @Cost,
                      0,
                      @MinP,
                      @Mpu,
                      @Sert_ID,
      								@Kol,
                      0,
                      0,
                      0,
                      0,
                      @DateR,
                      @Srokh,
                      @Country,
      								0,
                      @Locked,
                      @Producer,
                      @Gtd,
                      0,
                      @Our_ID,
                      @WEIGHT,
      								@ND, 
                      @MeasID,
                      @OnlyBox,
                      @DefContr,
                      @SafeCust,
                      @ProducerName,
                      @Lock,
                      @PinOwner,
                      @DCKOwner,
                      (select pin from def where ncod=@Ncod));
      
    -- Запись в Log при изменении блокировки
    if @Lock=2
      insert into Log (	OP,
      									Comp,
                        Tip,
                        MESS,
                        Param1,
                        Param2,
                        Param3,
                        Param4)
      select 						@OP,
      									host_name(),
                        'Блок',
                        'Блокировка, Hitag/ID/Rest/Lock:',
                        cast(@HITAG as varchar(15)),
                        cast(@TekID as varchar(15)),
                        cast(@Kol as varchar(15)),
                        cast(@Lock as varchar(15)); 
  
    -- Запись детализации прихода:
   insert into Inpdet(	nd, 
   											ncom, 
                        id, 
                        hitag, 
                        price, 
                        cost, 
                        kol,
      									sert_id,
                        minp,
                        mpu,
                        dater,
                        srokh,
                        nalog5,
                        op,
      									sklad,
                        kol_b,
                        summacost,
                        CountryID,
                        ProducerID,
                        [weight])
    values(							@nd, 
    										@newncom, 
                        @TekID, 
                        @hitag, 
                        @price, 
                        @cost, 
                        @kol,
      									@sert_id,
                        @minp,
                        @mpu,
                        @StrDateR,
                        CONVERT(varchar,@srokh,4),
                        0,
                        @op,
      									@sklad,
                        0,
                        @cost*IsNull(@kol,0),
                        @Country,
                        @Producer,
                        @WEIGHT);
      
    --Запись или обновление таблицы отношений Номенклатура-Поставщик
    set @NDVend=Null;
    set @NDVend=(select nv.nd from NomenVend nv where DCK=@DefContr and hitag=@hitag);
    select 26;
    if @NDVend is Null 
      begin
        insert into NomenVend (	Hitag,
        												ExtTag,
                                Ncod,
                                nd,
                                DCK,
                                cost,
                                price,
                                pin)
        values (								@hitag,
        												Null,
                                @Ncod,
                                @ND,
                                @DefContr,
                                @cost,
                                @price,
                                (select pin from def where ncod=@Ncod));
      end; 
      else 
      begin
        update NomenVend set 	Nd=@ND, 
        											NomenVend.cost=@cost, 
                              NomenVend.price=@price, 
                              NomenVend.pin=(select pin from def where ncod=@Ncod)
        where DCK=@DefContr and hitag=@hitag
      end;

     fetch next from CurDet into  @hitag, @price, @cost, @sert_id, @minp,@mpu,
    @dater,@srokh,@Country,@sklad, @Locked,  @NDS, @Producer,@MeasID,
    @Netto,@Brutto,@flgWeight, @Gtd, @OnlyBox,@PrihodRDetKolStr,@ProducerName
 
  END; -- WHILE  
  close CurDet;
  deallocate CurDet;    
  
  update PrihodReq set PrihodRDate=GetDate(), PrihodRSaveTo=0  where PrihodRID=@PrihodRid;
  update PrihodReqDet set PrihodRDetNCom=@NewNcom where PrihodRID=@PrihodRid and PrihodRDetIsSave<>1;   
  update PrihodReqDet set PrihodRDetIsSave=1 where PrihodRID=@PrihodRid;
  update Comman set SummaPrice= (SELECT SUM(price*IsNull(kol,0))  from inpdet 
    where Ncom=@NewNcom) where Ncom=@NewNcom;  
  update Comman set SummaCost= (SELECT SUM(cost*IsNull(kol,0))  from inpdet 
    where Ncom=@NewNcom) where Ncom=@NewNcom;
  
  select @NewNcom;  
  COMMIT;
end