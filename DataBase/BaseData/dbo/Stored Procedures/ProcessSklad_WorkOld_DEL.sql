

CREATE procedure dbo.ProcessSklad_WorkOld_DEL
  -- Добавлена новая операция @Act="ИспВ", исправление веса. См. ниже.
  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  @remark varchar(40), @Newid int out, 
  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  @kolError int out, @Dck INT=0, @Junk int=0, 
  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran" и "ИспВ"
  
as
DECLARE
  @TekId int, @LastId int, @ND datetime, @STARTID int, @tm varchar(8), @Kol int, @NewKol INT,
  @flgWeight bit, @NCOM int,  @NCOD int,  @DATEPOST datetime,  @PRICE decimal(13, 2),
  @START decimal(12, 3),  @STARTTHIS decimal(12, 3),  @HITAG int, @MaxID int,
  @SKLAD smallint,  @COST decimal(13, 5), @Pin int, @k0 int, @k1 int, @NewNcom int,
  @MINP int,  @MPU int,  @SERT_ID int, @RANG char(1),
  @MORN decimal(12, 3),  @SELL decimal(12, 3),  
  @ISPRAV decimal(12, 3),  @REMOV decimal(12, 3),  @BAD decimal(12, 3),
  @DATER datetime,  @SROKH datetime,  @COUNTRY varchar(15), @REZERV decimal(12, 3),
  @UNITS varchar(3),  @LOCKED bit,  @NCOUNTRY int, @Koeff decimal(12,6),
  @GTD varchar(23),  @OUR_ID smallint, @WEIGHT decimal(12, 3), @OnlyMinP bit=0, 
  @FirstNakl INT, @CountryID int,  @ProducerID int, @TomorrowSell decimal(10,3), @Rest decimal(10,3),
  @CountRec int

begin
--  SET XACT_ABORT ON
 -- SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  begin try
  set @kolError=0;

  BEGIN TRANSACTION PRSklad;
  set @ND = dbo.today();
  set @tm = convert(varchar(8), getdate(), 108);
  if isnull(@SerialNom,0)=0 set @SerialNom=(SELECT max(isnull(SerialNom,0)) from Izmen)+1;
  
  
  /***************************************************************************
   *    КОРРЕКЦИЯ ВЕСА                                                       *
   ***************************************************************************/  
  if @Act='ИспВ' begin    

    -- Исходные данные, пригодятся для записи в IZMEN:
    select @startid=startid, @datepost=datepost, 
       @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=pin,
       @Kol=(morn-sell+isprav-remov)
    from tdvi where id=@id;

    -- Не полагаюсь на то, что новые цены будут переданы в процедуру, вычисляю:
    if @Weight<>0 begin -- но если исходный вес нулевой, то новых цен не вычислить!
      set @Koeff=@NewWeight/@Weight;
      set @NewPrice=@Price*@Koeff;
      set @NewCost=@Cost*@Koeff;
    end;
	
    -- Параметры: @Delta - это сколько строк с новым весом @NewWeight должно появиться на складе.
    -- Всегда создадим новую строку:
	set @NewId=1+(select max(ID) from tdVi);
	insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
		hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
		remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
		gtd, vitr, our_id, weight, DCK, Countryid, Producerid, Pin)
	values(@nd, @newid,@startid,@ncom,@ncod,@datepost,@Newprice,0,0,
		@hitag, @sklad, @Newcost, 0, @minp, @mpu, @sert_id, @rang, 0, 0,@Delta,
		0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
		@gtd, 0, @our_id, @NewWeight, @DCK, @Countryid, @ProducerID, @Pin); 
    if @@Error<>0 set @KolError=@KolError + 1024;
		
	-- Явно в исходной строке надо подправить количество:
	update TDVI set Isprav=Isprav-@Delta where ID=@ID;

	-- Журнал для исходной строки:
    insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
      ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,
      newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin)
    values(@nd,@tm,@act,@id,@id,@kol,@kol-@Delta,@price,@price,@cost,@cost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag, @Weight,@Weight, @ServiceFlag, @Pin);
    if @@Error<>0 set @KolError=@KolError + 2048;
	-- Журнал для новой строки:
    insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
      ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,
      newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin)
    values(@nd,@tm,@act,@id,@newid,0,@Delta,@price,@newprice,@cost,@newcost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag, 0,@NewWeight, @ServiceFlag, @Pin);
    if @@Error<>0 set @KolError=@KolError + 2048;
  end;


  /*****************************************************************
   *    КОРРЕКЦИЯ КОЛИЧЕСТВА                                       *
   *****************************************************************/  
  else if @Act='Испр' begin    
    -- Коррекция количества в существующей строке?
    if exists(select * from tdvi where id=@ID) BEGIN -- Да:
      set @Kol=(select(morn-sell+isprav-remov) from tdvi where id=@ID);
      update tdVi set Isprav=Isprav+@Delta, Start=Start+@Delta, Startthis=Startthis+@Delta where id=@id;      
    end; 
    else begin -- нет, добавляем новую строку:
      insert into tdVI(ID,StartId,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,Sklad,Cost,MinP,Mpu,Sert_ID,Rang,Morn,Sell,
         Isprav,Remov,Bad,DateR,SrokH,Country,CountryID,ProducerID,Rezerv,Units,Locked,Ncountry,Gtd,Our_ID,Weight, Dck, pin)
      select
         ID,StartId,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,@NewSklad,Cost,MinP,Mpu,Sert_ID,Rang,0,0,
         @Delta,0,0,DateR,SrokH,Country,CountryID,ProducerID,Rezerv,Units,0,Ncountry,Gtd,Our_ID,Weight, Dck, pin
      from Visual where id=@ID;
      set @Kol=0;
    end;
    if @@Error<>0 set @KolError=@KolError + 1

    set @NewKol=@Kol+@Delta;
     update Visual set Isprav=Isprav+@Delta where id=@id;      
    if @@Error<>0 set @KolError=@KolError + 2
        
    select @NewPrice=Price, @NewCost=Cost, @Ncod=ncod, @Ncom=Ncom, @NewSklad=Sklad,
           @hitag=hitag, @Dck=dck, @NewWeight=Weight, @Weight=Weight, @Pin=pin
    from tdvi where id=@ID;
    if @@Error<>0 set @KolError=@KolError + 4

    insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
      ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, hitag, 
      NewHitag, irID, DivFlag, Weight,NewWeight, ServiceFlag)
    values(@nd,@tm,@act,@id,@id,@kol,@newkol,@Newprice,@newprice,@Newcost,@newcost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag);
    if @@Error<>0 set @KolError=@KolError + 8
    
    insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
      ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,
      newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin)
    values(@nd,@tm,@act,@id,@id,@kol,@newkol,@Newprice,@newprice,@Newcost,@newcost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag, @Pin);
    if @@Error<>0 set @KolError=@KolError + 16

  end;


  /*****************************************************************
   *    ПЕРЕМЕЩЕНИЕ МЕЖДУ СКЛАДАМИ                                 *
   *****************************************************************/  
  else if (@Act='Скла') and exists(select id from tdvi where id=@ID and morn-sell+isprav-remov>0) BEGIN -- Что-то есть на складе.

    select @startid=startid, @datepost=datepost, @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=pin
    from tdvi where id=@id;
    if @@Error<>0 set @KolError=@KolError + 1
    if(@dater<'19500101') set @dater=null;
    if(@srokh<'19500101') set @srokh=null;
    
    
    -- Не отложен ли товар на завтра? Если отложен, его придется вычесть из текущих продаж
    set @FirstNakl=dbo.InDatNom(1,@ND); -- первая сегодняшняя накладная
  	/*set @TomorrowSell = isnull((select SUM(nv.kol) 
      from NV 
      inner join NC on NC.datnom=NV.datnom 
      where nv.DatNom>=@FirstNakl
      and nv.tekid=@ID
      and nc.Tomorrow=1),0)*/

    set @Rest=@morn+@isprav-@remov-@sell -- это расчетный остаток 
      -- на момент сейчас, включая отложенный на завтра.

    -- Дополнительный лог перемещений, необязательная вещщь:
    -- insert into MoveLog (ID,Rest,GoodQty,BadQty, NewSklad, Rezerv)
    --  values  (@ID,@Rest,@Delta,0, @NewSklad, @rezerv)
    
    -- Если переместить нужно весь остаток целиком - то в табл. TDVI только номер склада поменяется:
    if (abs(@rest-@Delta)<0.001) and (@sell = 0) and (@isprav=0) and (@remov=0) begin
    
      update TDVI set Sklad=@NewSklad where ID=@ID;    
      if @@Error<>0 set @KolError=@KolError + 2
      
      insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp, SerialNom,dck)
        values(@nd,@tm,'Скла',@id,@id,@rest,@rest,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom, @DCK);
      if @@Error<>0 set @KolError=@KolError + 4
        
      insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,
        cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,Hitag,DivFlag,NewHitag,Weight,NewWeight,dck,pin)
      values(@nd,@tm,'Скла',@id,@id,@rest,@rest,@price,@price,
        @cost,@cost,@ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@hitag,0,@hitag, @Weight, @Weight, @DCK,@Pin);
      if @@Error<>0 set @KolError=@KolError + 8

      set @NewId=@Id;
      select @NewId;
    end
    else 
    if (@rest>=@Delta)
    begin  -- Теперь - если появилась новая строка в tdVI:
      set @NewId=1+(select max(ID) from tdVi);

      insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        gtd, vitr, our_id, weight, DCK, Countryid, Producerid, Pin)
      values(@nd, @newid,@startid,@ncom,@ncod,@datepost,@price,@start,@Delta,
        @hitag, @newsklad, @cost, 0, @minp, @mpu, @sert_id, @rang, @Delta, 0,0,
        0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
        @gtd, 0, @our_id, @weight, @DCK, @Countryid, @ProducerID, @Pin); 
      if @@Error<>0 set @KolError=@KolError + 16
     
      insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck)
        values(@nd,@tm,'Скла',@id,@newid,@Delta,@Delta,@price,@price,@cost,@cost,@ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck);
      if @@Error<>0 set @KolError=@KolError + 32

      insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,
        cost,newcost,ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,Hitag,DivFlag,NewHitag,Weight,NewWeight,dck, Pin)
      values(@nd,@tm,'Скла',@id,@newid,@Delta,@Delta,@price,@price,
        @cost,@cost,@ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@hitag,0,@hitag,@Weight,@Weight,@dck, @Pin);
      if @@Error<>0 set @KolError=@KolError + 64

      update TDVI set morn=Morn-@Delta, StartThis=StartThis-@Delta where ID=@ID;
      if @@Error<>0 set @KolError=@KolError + 128
      select @NewId;
    end    
    else set @KolError=@KolError + 256
    
  end; -- Act='СКЛА'



  /*****************************************************************
   *    ПЕРЕОЦЕНКА                                                 *
   *****************************************************************/  
   else if @Act='ИзмЦ'  begin
     
     -- Какие были старые данные по текущей строке в TDVI?  
     select @startid=startid, @datepost=datepost, 
       @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=pin
     from tdvi where id=@id;
 
     set @Delta=@Morn-@Sell+@Isprav-@Remov;

     update TDVI set Price=@NewPrice, Cost=@NewCost where id=@ID;

     insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
     ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight)
        values(@nd,@tm,@act,@id,@id,@Delta,@Delta,@price,@newprice,@cost,@newcost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight);
     if @@Error<>0 set @KolError=@KolError + 1

     insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
     ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight, Pin)
        values(@nd,@tm,@act,@id,@id,@Delta,@Delta,@price,@newprice,@cost,@newcost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight, @Pin);
     if @@Error<>0 set @KolError=@KolError + 2
     
     update Nomen  set Price=@NewPrice, Cost=@NewCost where hitag=@Hitag;
     if @@Error<>0 set @KolError=@KolError + 4
          
     update NomenVend set Price=@NewPrice where hitag=@Hitag and DCK=@DCK
     
     if (@Cost<>@NewCost) begin
       update Comman set Izmen=Izmen+(@NewCost-@Cost)*@Delta where Ncom=@Ncom;
       if @@Error<>0 set @KolError=@KolError + 8
     end;
     
     --update nomenvend set price=@newprice where pin=@pin and dck=@dck and hitag=@Hitag
     --Падает триггер! Который привязан к Nomen_LOG  
     if @@Error<>0 set @KolError=@KolError + 16
   end;
      
   
  /*****************************************************************
   *    ВОЗВРАТ ПОСТАВЩИКУ                                         *
   *****************************************************************/  
   else if (@Act='Снят')  begin
   
     -- Какие были старые данные по текущей строке в TDVI?  
     select @startid=startid, @datepost=datepost, 
       @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=pin
     from tdvi where id=@id;
     set @FlgWeight=(select FlgWeight from nomen where hitag=@hitag);
     set @kol=@morn-@sell+@isprav-@remov
     set @newkol=@kol-@Delta
     if (@newKol<0)and(@Hitag<>95007)and(@Hitag<>90858) set @KolError=64;
     else begin
       if (@Ncom<0) and (not Exists(select * from comman where ncom=@Ncom))
       insert into Comman(ncom,ncod,comman.[DATE],comman.[time],summaprice,summacost,
          izmen,isprav,comman.[REMOVE],ostat,corr,plata,srok,our_id,dck) 
       values(@ncom,@ncod, '20050101','08:00:00',0,0,0,0,0,0,0,0,0,@our_id,@Dck);
       if @@Error<>0 set @KolError=@KolError + 1
  

       if @flgWeight=0 begin set @weight=0; set @NewWeight=0; end;
       else begin
         set @NewWeight=@Weight*@newKol;
         set @WEIGHT=@weight*@kol;
       end;

       update Comman set Remove=Remove-@Cost*@Delta where Ncom=@Ncom;
       if @@Error<>0 set @KolError=@KolError + 2
       update Visual set Remov=Remov+@Delta where id=@id;
       if @@Error<>0 set @KolError=@KolError + 4
       update tdVi set Remov=Remov+@Delta where id=@id;     
       if @@Error<>0 set @KolError=@KolError + 8
      
       insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
          ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, hitag, NewHitag,
          irID, DivFlag, Weight,NewWeight, ServiceFlag)
       values(@nd,@tm,@act,@id,@id,@kol,@newkol,@price,@newprice,@cost,@newcost,
          @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, @hitag, 
          @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag);
       if @@Error<>0 set @KolError=@KolError + 16
        
       insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
          ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,newHitag, 
          irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin)
       values(@nd,@tm,@act,@id,@id,@kol,@newkol,@price,@newprice,@cost,@newcost,
          @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck,@hitag, @hitag, 
          @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag, @Pin);
       if @@Error<>0 set @KolError=@KolError + 32
     end;     
  end;

  /********************************************************************
  *    ТРАНСМУТАЦИЯ. Отличие от других веток: используются параметры  *
  *    @TransmDec, @TransmAdd, @NewNcod                               *
  ********************************************************************/  
  else if (@Act='Тран')  begin
    select 
      @kol=morn-sell+isprav-remov,
      @Hitag=Hitag, @Ncod=ncod, @Ncom=Ncom, @Price=Price, 
      @Cost=Cost, @Sklad=Sklad,  @Dck=dck, @pin=pin
    from TDVI where id=@ID;
    
    if @kol-@TransmDec<0 set @KolError=64;
    else begin
      select @minp=minp, @mpu=mpu from nomen where hitag=@NewHitag

      set @NewId=(select max(id) from tdVi)+1;

      insert into tdIZ(act,id,newid,kol,newkol,price,newprice,cost,newcost, SerialNom,
        ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag)
      values(@Act,@id,@newid,@TransmDec,@TransmAdd,@price,@newprice,@cost,@newcost, @SerialNom,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@dck, @hitag, @newhitag);
      if @@Error<>0 set @KolError=@KolError + 1
      
      insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost,SerialNom,
        ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag, Pin)
      values('Tran',@id,@newid,@TransmDec,@TransmAdd,@price,@newprice,@cost,@newcost,@SerialNom,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@dck, @hitag, @newhitag, @Pin);
      if @@Error<>0 set @KolError=@KolError + 2
      
      insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        gtd, vitr, our_id, weight,dck, Pin, ProducerID)
      select
        dbo.today() as ND,
        @newid, v.startid, @Ncom, @NewNcod, datepost, @NewPrice, 0,0,
        @NewHitag, @Sklad, @NewCost, 0, @MinP, @Mpu, v.Sert_Id, '5', 0,0,@TransmAdd,
        0,0,v.dater, v.srokh, v.country, 0, v.units, v.locked, v.ncountry,
        v.gtd,0,v.our_id, @NewWeight, @Dck, @Pin,ProducerID
      from tdvi v
      where v.ID=@ID;
      if @@Error<>0 set @KolError=@KolError + 4
      
      update tdvi set Isprav=isnull(Isprav,0)-@TransmDec where id=@id;
      if @@Error<>0 set @KolError=@KolError + 8
    end;
  end;


  /*****************************************************************
   *    РАЗБИЕНИЕ                                                  *
   *****************************************************************/  
  else if (@Act='Div-')  begin 
  
    select @TekID=p.id, @StartID=v.StartID, @Hitag=p.Hitag, @Sklad=p.Sklad, @WEIGHT=v.Weight,
        @Price=p.Price, @Cost=p.Cost, @MinP=v.Minp, @Mpu=v.Mpu, @Sert_ID=v.Sert_ID, 
        @Ncod=v.ncod, @Ncom=v.Ncom, @Dck=v.dck, @DatePost=v.DatePost,
        @Dater=v.dater, @Srokh=V.srokh, @Country=v.Country, @NCountry=v.NCountry, 
        @CountryID=v.CountryID, @gtd=v.gtd, @Our_ID=v.Our_ID, @Units=v.Units,
        @Locked=v.Locked, @pin=v.pin,
        @Kol=v.morn-v.sell+v.isprav-v.remov, @NewKol=v.morn-v.sell+v.isprav-v.remov-P.Qty, @ProducerID=v.ProducerID
    from 
        ParamSklad p
        inner join Tdvi v on v.id=p.Id
    where p.Comp=@comp and p.id>0;   
    
    set @NewWEIGHT=iif(@newkol=0,0,@Weight);
	-- sum(p.Weight*p.qty)
    --  from ParamSklad p where p.Comp=@Comp and p.Nomer>0
    
    if @Kol<=0 set @kolError=64;
    else begin
      insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost, 
        ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
        hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Smi, Pin)
      values (@act,@tekid,@tekid,@kol,@newkol,@Price,@price,@cost,@cost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, 
        @hitag, 0, @irId, 1, @Weight,@NewWEIGHT, @ServiceFlag, @Cost*(@NewKol-@Kol), @Pin)
      if @@Error<>0 set @KolError=@KolError + 1
        
      insert into tdiz(act,id,newid,kol,newkol,price,newprice,cost,newcost, 
        ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
        hitag,newhitag, irId, DivFlag, Weight,NewWeight, ServiceFlag)
      values (@act,@tekid,@tekid,@kol,@newkol,@Price,@price,@cost,@cost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, 
        @hitag, 0, @irId, 1, @Weight,@NewWEIGHT, @ServiceFlag)
      if @@Error<>0 set @KolError=@KolError + 2

      set @LastID=(select max(ID) from tdVi); 
      
      insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        CountryID, gtd, vitr, our_id, weight,dck, Pin,ProducerID)
      select
        @ND as nd, @LastID+p.Nomer as id, @startid as StartId, @Ncom ncom, @Ncod ncod, 
        @datepost datepost, P.Price price, 0 as start,0 as StartThis,
        p.hitag, p.Sklad sklad, p.Cost cost, 0 as Nalog5, nm.MinP, nm.Mpu, 
        @Sert_Id sert_id, '5' as Rang, 0 as morn,0 as sell,p.qty as isprav,
        0 as remov,0 as bad, @dater as dater, @srokh as srokh, @country as country, 
        0 as rezerv, @units as units, @locked as locked, @ncountry as ncountry,
        @CountryID as CountryID, @gtd as gtd,0 as vitr,@our_id as our_id, 
        p.Weight as weight, @Dck as dck, @Pin as Pin, @ProducerID as ProducerID
      from ParamSklad p 
        inner join Nomen nm on nm.hitag=p.hitag
      where p.Comp=@comp and p.Nomer>0;
      
      if @@Error<>0 set @KolError=@KolError + 4

      set @NewID=(select max(p.nomer)+@LastID from ParamSklad p where p.Comp=@comp and p.Nomer>0);
     
      insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost, 
        ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
        hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Smi, Pin)
      select 'div+', @tekid, @LastID+p.Nomer,0,p.qty,p.Price,p.price,p.cost,p.cost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, 
        @hitag, p.hitag, @irId, 1, 0/*@Weight*/,p.Weight, @ServiceFlag, p.Qty*p.Cost as Smi, @Pin
      from ParamSklad p where p.Comp=@Comp and p.Nomer>0 order by Nomer
      if @@Error<>0 set @KolError=@KolError + 8
      
      insert into tdiz(act,id,newid,kol,newkol,price,newprice,cost,newcost, 
        ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
        hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag)
      select 'div+',@TekId, @LastID+p.Nomer,0,p.qty,p.Price,p.price,p.cost,p.cost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, 
        @hitag, p.hitag, @irId, 1, p.Weight,p.Weight, @ServiceFlag
      from ParamSklad p where p.Comp=@Comp and p.Nomer>0 order by Nomer 
      if @@Error<>0 set @KolError=@KolError + 16


      update tdvi set isprav=isprav-(select p.qty from paramsklad p where p.Id=tdvi.id and p.Comp=@comp)
      where tdvi.id=@TekId;
    
      if @@Error<>0 set @KolError=@KolError + 32;
      -- select @NewID;
    end;
  end;

  /*****************************************************************
   *    СЛИЯНИЕ                                                    *
   *****************************************************************/  
  else if (@Act='Div+')  begin

    set @Locked=0;
    
    if EXISTS(select p.* from ParamSklad p inner join TDVI V on V.id=p.Id 
    where p.Comp=@Comp and p.Nomer>0 and v.morn-v.sell+v.isprav-v.remov<=0)
    set @KolError=64;
    else begin    
      select @Weight=Weight,@Hitag=Hitag, @Sklad=Sklad,@Price=Price,@Cost=Cost 
      from ParamSklad where Comp=@Comp and Nomer=0;
      
      set @Pin=(select max(pin) from def where Ncod=@NewNcod);
      set @LastID=(select max(ID) from tdVi); 
      select @Minp=MinP, @Mpu=Mpu, @Sert_id=Sert_Id from Nomen where Hitag=@Hitag;

      -- Если все NCOM совпадают, то это и будет новый NCOM. 
      -- А если нет, тогда это -NewNCOD:
      select @k0=min(tdvi.ncom), @k1=max(tdvi.NCOM) 
      from ParamSklad p inner join tdvi on tdvi.id=p.Id
      where p.Comp=@Comp and p.Nomer>0;
      if @k0=@k1 set @NewNcom=@k0; else set @NewNcom=-@NewNcod;
      
      --set @our_id=(select our_id from defcontract where dck=@dck);
      -- @Our_ID определяется по первой исходной строке таблицы параметров:
      if exists(select 1 from ParamSklad p inner join TDVI V on V.id=p.Id  where p.Comp=@Comp and p.Nomer=1 and p.id is not null)
        select @our_id=v.our_id 
        from ParamSklad p 
        inner join TDVI V on V.id=p.Id 
        where p.Comp=@Comp 
              and p.Nomer=1
      else
      	set @our_id=(select our_id from defcontract where dck=@dck)
      
      set @MaxID=(select max(id) from tdvi where Hitag=@Hitag);
      if @MaxId is null begin
        set @MaxID=(select max(id) from Visual where Hitag=@Hitag);
        select @Units=Units, @Gtd=Gtd, @Dater=Dater, @Srokh=Srokh, @Ncountry=Ncountry, 
          @Country=Country, @CountryID=CountryID,@ProducerID=ProducerID 
		  from Visual where id=@MaxID;    
      end;
      else 
        select @Units=Units, @Gtd=Gtd, @Dater=Dater, @Srokh=Srokh, @Ncountry=Ncountry, 
          @Country=Country, @CountryID=CountryID,@ProducerID=ProducerID 
		  from TDVI where id=@MaxID;    


       -- Новая строка в TDVI:
       insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
         hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
         remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
         CountryID, gtd, vitr, our_id, weight,dck,pin,ProducerID)
       select
         @ND, @LastID+1, @LastID+1, @NewNcom, @NewNcod, dbo.today(), P.Price, 0,0,
         @Hitag, p.Sklad, p.Cost, 0, @MinP, @Mpu, @Sert_Id, '5', 0,0,p.qty,
         0,0,@dater, @srokh, @country, 0, @units, @locked, @ncountry,
         @CountryID, @gtd,0,@our_id, @Weight, @Dck,@Pin,@ProducerID
       from ParamSklad p 
       where p.Comp=@comp and p.act='Div+' and p.Nomer=0;
       if @@Error<>0 set @KolError=@KolError + 1

       -- И в журнал;
       insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
         ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
         hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag,Pin)
       select @nd,@tm,'Div+', 0, @LastID+1,0,p.qty,p.Price,p.price,p.cost,p.cost,
         @newncod,@NewNcom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
         @hitag, @irId, 0, 0, @Weight, @ServiceFlag,@Pin
       from ParamSklad p where p.Comp=@Comp and p.Nomer=0;
       if @@Error<>0 set @KolError=@KolError + 2;

       insert into tdiz(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
         ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
         hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag)
       select @nd,@tm,'div+', 0, @LastID+1,0,p.qty,p.Price,p.price,p.cost,p.cost,
         @newncod,@NewNcom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
         @hitag, @irId, 1, p.Weight,p.Weight, @ServiceFlag
       from ParamSklad p where p.Comp=@Comp and p.Nomer=0;
       if @@Error<>0 set @KolError=@KolError + 4
       
       -- И в журнал строки, которые сливаются в одну:;
       insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost, 
         ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
         hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, pin)
       select 'div-', p.id, p.id,v.morn-v.sell+v.isprav-v.remov,v.morn-v.sell+v.isprav-v.remov-p.qty,p.Price,p.price,p.cost,p.cost,
         v.ncod,v.ncom,@op,v.sklad,v.sklad,@remark,0,@comp,@SerialNom,v.dck, v.hitag, 
         @hitag, @irId, 0, p.Weight,0, @ServiceFlag, v.pin
       from 
         ParamSklad p 
         inner join tdvi v on v.id=p.id     
       where p.Comp=@Comp and p.Nomer>0;
       if @@Error<>0 set @KolError=@KolError + 8
       
       insert into tdiz(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
         ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, 
         hitag,newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag)
       select @nd,@tm,'div+', p.id, p.id,v.morn-v.sell+v.isprav-v.remov,v.morn-v.sell+v.isprav-v.remov-p.qty,p.Price,p.price,p.cost,p.cost,
         v.ncod,v.ncom,@op,v.sklad,v.sklad,@remark,0,@comp,@SerialNom,v.dck, v.hitag, 
         @hitag, @irId, 1, p.Weight,0, @ServiceFlag
       from 
         ParamSklad p 
         inner join tdvi v on v.id=p.id     
       where p.Comp=@Comp and p.Nomer>0;
       if @@Error<>0 set @KolError=@KolError + 16
                 
       -- Коррекция склада по строкам, которые сливаются в одну:
       update tdvi 
       set isprav=isprav-(select Qty from ParamSklad where comp=@comp and nomer>0 and id=tdVi.id)
       where id in (select id from ParamSklad where comp=@comp and nomer>0);
       if @@Error<>0 set @KolError=@KolError + 32;
     end;     
  end;
  if @KolError=0 COMMIT TRANSACTION PRSklad; -- WITH (DELAYED_DURABILITY = ON); --else Rollback;
  end try
  begin catch
    -- SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    IF (XACT_STATE())<>1
    BEGIN
      ROLLBACK TRANSACTION PRSklad;
	  INSERT INTO PROCERRORS(ERRNUM, ERRMESS, PROCNAME, ERRLINE) SELECT ERROR_NUMBER(), 'PROCESSSKLAD: ' + + ERROR_MESSAGE(), OBJECT_NAME(@@PROCID), ERROR_LINE()    	               
      set @kolError=4096;
      return @kolError;
    END;
  end catch 
  --SET XACT_ABORT OFF     
end;