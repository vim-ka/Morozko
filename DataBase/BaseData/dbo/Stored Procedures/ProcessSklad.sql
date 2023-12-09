CREATE procedure dbo.ProcessSklad --избавиться от tdiz
  @Act char(4), -- допустимые операции: Испр, Скла, ИзмЦ, Снят.
  @ID int, @NewHitag int=0, @NewSklad smallint, 
  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta DECIMAL(12,3), 
  @Op int, @Comp varchar(30),
  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  @remark varchar(40), @Newid int=0 out, 
  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  @kolError int out, @Dck INT=0, @Junk int=0, 
  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операций "Tran"
  
as
DECLARE
  @TekId int, @ND datetime, @STARTID int, @tm varchar(8), @Kol decimal(12,3), @NewKol decimal(12,3),
  @flgWeight bit, @NCOM int,  @NCOD int,  @DATEPOST datetime,  @PRICE decimal(13, 2),
  @START decimal(12, 3),  @STARTTHIS decimal(12,3),  @HITAG int, @MaxID int,
  @SKLAD smallint,  @COST decimal(13, 5), @Pin int, @k0 int, @k1 int, @NewNcom int,
  @MINP int,  @MPU int,  @SERT_ID int, @RANG char(1),
  @MORN decimal(12, 3),  @SELL decimal(12, 3),  
  @ISPRAV decimal(12, 3),  @REMOV decimal(12, 3),  @BAD decimal(12, 3),
  @DATER datetime,  @SROKH datetime,  @COUNTRY varchar(15), @REZERV decimal(12, 3),
  @UNITS varchar(3),  @LOCKED bit,  @NCOUNTRY int, @Koeff decimal(13,7),
  @GTD varchar(23),  @OUR_ID smallint, @WEIGHT decimal(12, 3), @OnlyMinP bit=0, 
  @FirstNakl INT, @CountryID int,  @ProducerID int, @TomorrowSell decimal(12,3), @Rest decimal(12,3),
  @CountRec int, @PriceVI decimal(13, 2), @UnID int

begin
--  SET XACT_ABORT ON
 -- SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  --begin try
  set @kolError=0;
  
 -- if not exists(select 1 from ParamSklad p where p.Comp=@Comp) 
 -- set @kolError=65536;

  BEGIN TRANSACTION PRSklad;
  set @ND = dbo.today();
  set @tm = convert(varchar(8), getdate(), 108);
  if isnull(@SerialNom,0)=0 set @SerialNom=(SELECT max(isnull(SerialNom,0)) from Izmen)+1;
  

  /****************************************************************
  *    КОРРЕКЦИЯ КОЛИЧЕСТВА                                       *
  ****************************************************************/  
  if @Act='Испр' begin    
    -- Коррекция количества в существующей строке?
    if exists(select * from tdvi where id=@ID) BEGIN -- Да:
      select @Kol=morn-sell+isprav-remov, @UnID=Unid from tdvi where id=@ID;
      update tdVi set Isprav=Isprav+@Delta, Start=Start+@Delta, Startthis=Startthis+@Delta 
        where id=@id;      
    end; 
    else begin -- нет, добавляем новую строку:
      set IDENTITY_INSERT [dbo].tdvi ON;
      
      insert into tdVI(ID,StartId,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,
         Sklad,Cost,MinP,Mpu,Sert_ID,Rang,Morn,Sell,Isprav,Remov,Bad,DateR,SrokH,
         Country,CountryID,ProducerID,Rezerv,Units,Locked,Ncountry,Gtd,Our_ID,Weight, Dck, pin, Unid)
      select
         ID,StartId,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,
         @NewSklad,Cost,MinP,Mpu,Sert_ID,Rang,0,0,@Delta,0,0,DateR,SrokH,
         Country,CountryID,ProducerID,Rezerv,Units,0,Ncountry,Gtd,Our_ID,0.0, -- было Weight, 
         Dck, pin, Unid
      from Visual where id=@ID;
      
      set IDENTITY_INSERT [dbo].tdvi OFF;
      set @Kol=0;
    end;
    if @@Error<>0 set @KolError=@KolError | 1

    set @NewKol=@Kol+@Delta;
    update Visual set Isprav=Isprav+@Delta where id=@id;      
    if @@Error<>0 set @KolError=@KolError | 2
        
    select @NewPrice=Price, @NewCost=Cost, @Ncod=ncod, @Ncom=Ncom, @NewSklad=Sklad,
           @hitag=hitag, @Dck=dck, @NewWeight=Weight, @Weight=Weight, @pin=isnull(pin,0)
    from tdvi where id=@ID;
    if @@Error<>0 set @KolError=@KolError | 4

    insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
      ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, hitag, 
      NewHitag, irID, DivFlag, Weight,NewWeight, ServiceFlag, Unid)
    values(@nd,@tm,@act,@id,@id,@kol,@newkol,@Newprice,@newprice,@Newcost,@newcost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag,
      0.0, 0.0, -- было @Weight,@NewWeight, 
      @ServiceFlag, @Unid);
    if @@Error<>0 set @KolError=@KolError | 8
    
    insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
      ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,
      newHitag, irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin, Unid)
    values(@nd,@tm,@act,@id,@id,@kol,@newkol,@Newprice,@newprice,@Newcost,@newcost,
      @ncod,@ncom,@op,@Newsklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, 
      @hitag, @irId, @DivFlag, 
      0.0, 0.0, -- было @Weight,@NewWeight, 
      @ServiceFlag, @Pin, @Unid);
    if @@Error<>0 set @KolError=@KolError | 16

  end;


  /*****************************************************************
   *    ПЕРЕМЕЩЕНИЕ МЕЖДУ СКЛАДАМИ                                 *
   *****************************************************************/  
  else if (@Act='Скла') and exists(select id from tdvi where id=@ID and morn-sell+isprav-remov>0 and id>0) BEGIN -- Что-то есть на складе.
    PRINT('  - PROCESSSKLAD, вход в модуль перемещения...');
    select @startid=startid, @datepost=datepost, @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=isnull(pin,0), @Unid=Unid
    from tdvi where id=@id;
    if @@Error<>0 set @KolError=@KolError | 1
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


    --if (@rest>=@Delta)
    begin  -- Теперь - если появилась новая строка в tdVI:

      insert into tdVi(nd,startid,ncom,ncod,datepost,price,start,startthis,
        hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
        remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
        gtd, vitr, our_id, weight, DCK, Countryid, Producerid, Pin, Unid)
      values(@nd, @startid,@ncom,@ncod,@datepost,@price,@start,@Delta,
        @hitag, @newsklad, @cost, 0, @minp, @mpu, @sert_id, @rang, @Delta, 0,0,
        0,0, @dater, @srokh, @country, 0, @units, @locked, @ncountry,
        @gtd, 0, @our_id, 
        0.0, -- было @weight, 
        @DCK, @Countryid, @ProducerID, @Pin, @Unid); 
      
      if @@Error<>0 set @KolError=@KolError | 16  
      
      set @NewID=SCOPE_IDENTITY();
      PRINT('  - PROCESSSKLAD, произошла вставка NEWID='+cast(@NewID as varchar));
     
      insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,
        ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Unid)
      values(@nd,@tm,'Скла',@id,@newid,@Delta,@Delta,@price,@price,@cost,@cost,@ncod,
        @ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @Unid);
      if @@Error<>0 set @KolError=@KolError | 32

      insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,ncod,
        ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,Hitag,DivFlag,NewHitag,Weight,NewWeight,dck, Pin,Unid)
      values(@nd,@tm,'Скла',@id,@newid,@Delta,@Delta,@price,@price,@cost,@cost,@ncod,
        @ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@hitag,0,@hitag,
        0.0, 0.0, -- было @Weight,@Weight,
        @dck, @Pin, @Unid);
      if @@Error<>0 set @KolError=@KolError | 64

      update TDVI set morn=Morn-@Delta, StartThis=StartThis-@Delta where ID=@ID;
      if @@Error<>0 set @KolError=@KolError | 128
      select @NewId;
    end    
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
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=isnull(pin,0),@Unid=Unid
     from tdvi where id=@id;
    SET @Weight=0.0; SET @NewWeight=0.0;
 
     set @Delta=@Morn-@Sell+@Isprav-@Remov;

     update TDVI set Price=@NewPrice, Cost=@NewCost where id=@ID;

     insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
        ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight, Unid)
     values(@nd,@tm,@act,@id,@id,@Delta,@Delta,@price,@newprice,@cost,@newcost,
        @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight, @Unid);
     if @@Error<>0 set @KolError=@KolError | 1

     insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
       ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight, Pin,Unid)
     values(@nd,@tm,@act,@id,@id,@Delta,@Delta,@price,@newprice,@cost,@newcost,
       @ncod,@ncom,@op,@sklad,@sklad,@remark,0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight, @Pin,@Unid);
     if @@Error<>0 set @KolError=@KolError | 2
     
     update Nomen set Price=@NewPrice, Cost=@NewCost where hitag=@Hitag;
     if @@Error<>0 set @KolError=@KolError | 4
          
     update NomenVend set Price=@NewPrice where hitag=@Hitag and DCK=@DCK
     
     if (@Cost<>@NewCost) begin
       update Comman set Izmen=isnull(Izmen,0)+(isnull(@NewCost,0)-isnull(@Cost,0))*isnull(@Delta,0) where Ncom=@Ncom;
       if @@Error<>0 set @KolError=@KolError | 8
     end;
     
     --update nomenvend set price=@newprice where pin=@pin and dck=@dck and hitag=@Hitag
     --Падает триггер! Который привязан к Nomen_LOG  
     if @@Error<>0 set @KolError=@KolError | 16
  end;
      
   
  /******************************************************************************************************************************
  *    ВОЗВРАТ ПОСТАВЩИКУ. Если @NEWCOST<>@COST, то предварительно будет выполнена переоценка возвращаемого количества.        *
  ******************************************************************************************************************************/  
  else if (@Act='Снят')  begin
     -- Какие были старые данные по текущей строке в TDVI?  
     select @startid=startid, @datepost=datepost, 
       @start=start, @startthis=startthis,
       @hitag=hitag,@minp=minp,@mpu=mpu,@sert_id=sert_id,
       @rang=rang,@morn=morn,@sell=sell,@isprav=isprav,@remov=remov,@bad=bad,
       @dater=dater,@srokh=srokh,@country=country,@units=units,@locked=locked,
       @ncountry=ncountry,@gtd=gtd,@our_id=our_id,@WEIGHT=WEIGHT,@sklad=sklad, 
       @price=price, @cost=cost, @ncod=ncod, @ncom=ncom, @DCK=DCK, 
       @Countryid=Countryid, @ProducerID=ProducerID, @rezerv=rezerv, @pin=isnull(pin,0),@Unid=Unid
     from tdvi where id=@id;
     SELECT @Weight=0.0, @NewWeight=0.0;

     set @FlgWeight=(select FlgWeight from nomen where hitag=@hitag);
     set @kol=@morn-@sell+@isprav-@remov
     set @newkol=@kol-@Delta
     if (@newKol<0)and(@Hitag<>95007)and(@Hitag<>90858) set @KolError=@KolError | 512;
     else begin
       if (@Ncom<0) and (not Exists(select * from comman where ncom=@Ncom))
       insert into Comman(ncom,ncod,[DATE],[time],summaprice,summacost,izmen,isprav,[REMOVE],ostat,corr,plata,srok,our_id,dck) 
       values(@ncom,@ncod,'20050101','08:00:00',0,0,0,0,0,0,0,0,0,@our_id,@Dck);
       if @@Error<>0 set @KolError=@KolError | 1
  

       if @flgWeight=0 begin set @weight=0; set @NewWeight=0; end;
       else begin
         set @NewWeight=@Weight*@newKol;
         set @WEIGHT=@weight*@kol;
       end;

      /* Пока отключено:
       if @NewCost<>@COST BEGIN -- возможная переоценка возвращаемого количества:
         insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
           ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight)
         values(@nd,@tm,'ИзмЦ',@id,@id,@Delta,@Delta,@price,@price,@cost,@newcost,
           @ncod,@ncom,@op,@sklad,@sklad,'reassessment',0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight);
         if @@Error<>0 set @KolError=@KolError | 1
    
         insert into izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
           ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, Hitag,NewHitag,IrId, Weight, NewWeight, Pin)
         values(@nd,@tm,'ИзмЦ',@id,@id,@Delta,@Delta,@price,@price,@cost,@newcost,
           @ncod,@ncom,@op,@sklad,@sklad,'reassessment',0,@comp,@SerialNom,@dck,@Hitag,@Hitag,@IrId, @Weight, @Weight, @Pin);
         if @@Error<>0 set @KolError=@KolError | 2
       END;
       */

       update Comman set Remove=isnull(Remove,0)-isnull(@NewCost,0)*isnull(@Delta,0) where Ncom=@Ncom;
       if @@Error<>0 set @KolError=@KolError | 2
       update Visual set Remov=Remov+@Delta where id=@id;
       if @@Error<>0 set @KolError=@KolError | 4
       update tdVi set Remov=Remov+@Delta where id=@id;     
       if @@Error<>0 set @KolError=@KolError | 8
      
       insert into tdIZ(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost,
          ncod,ncom,op,sklad,newsklad,remark,printed,comp,SerialNom,dck, hitag, NewHitag,
          irID, DivFlag, Weight,NewWeight, ServiceFlag,Unid)
       values(@nd,@tm,@act,@id,@id,@kol,@newkol,@price,@price,@newcost,@newcost,
          @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck, @hitag, @hitag, 
          @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag,@Unid);
       if @@Error<>0 set @KolError=@KolError | 16
        
       insert into Izmen(nd,tm,act,id,newid,kol,newkol,price,newprice,cost,newcost, 
          ncod, ncom, op, sklad, newsklad, remark,printed,comp, SerialNom,dck, hitag,newHitag, 
          irId, DivFlag, Weight,NewWeight, ServiceFlag, Pin,Unid)
       values(@nd,@tm,@act,@id,@id,@kol,@newkol,@price,@price,@newcost,@newcost,
          @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@SerialNom,@dck,@hitag, @hitag, 
          @irId, @DivFlag, @Weight,@NewWeight, @ServiceFlag, @Pin,@Unid);
       if @@Error<>0 set @KolError=@KolError | 32
     end;     
  end;
  ELSE SET @KolError=2048; -- недопустимая операция

  print('KolError='+cast(@kolError as varchar));
  if @KolError=0 COMMIT TRANSACTION PRSklad else ROLLBACK TRANSACTION PRSklad; -- WITH (DELAYED_DURABILITY = ON); --else Rollback;
/*  end try
  begin catch
    -- SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    IF (XACT_STATE())<>1
    BEGIN
      ROLLBACK TRANSACTION PRSklad;
	  INSERT INTO PROCERRORS(ERRNUM, ERRMESS, PROCNAME, ERRLINE) SELECT ERROR_NUMBER(), 'PROCESSSKLAD: ' + + ERROR_MESSAGE(), OBJECT_NAME(@@PROCID), ERROR_LINE()    	               
      set @kolError=4096;
      return @kolError;
    END;
  end catch */
  --SET XACT_ABORT OFF     
end;