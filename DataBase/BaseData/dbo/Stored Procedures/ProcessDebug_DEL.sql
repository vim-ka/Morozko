

CREATE procedure ProcessDebug_DEL
  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  @remark varchar(40), @Newid int out, 
  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  @kolError int out, @Dck INT=0, @Junk int=0, 
  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операции "Tran"
  
as
DECLARE
  @TekId int, @LastId int, @ND datetime, @STARTID int, @tm varchar(8), @Kol int, @NewKol INT,
  @flgWeight bit, @NCOM int,  @NCOD int,  @DATEPOST datetime,  @PRICE decimal(13, 2),
  @START decimal(12, 3),  @STARTTHIS decimal(12, 3),  @HITAG int,
  @SKLAD smallint,  @COST decimal(13, 5), @Pin int,
  @MINP int,  @MPU int,  @SERT_ID int, @RANG char(1),
  @MORN decimal(12, 3),  @SELL decimal(12, 3),  
  @ISPRAV decimal(12, 3),  @REMOV decimal(12, 3),  @BAD decimal(12, 3),
  @DATER datetime,  @SROKH datetime,  @COUNTRY varchar(15), @REZERV decimal(12, 3),
  @UNITS varchar(3),  @LOCKED bit,  @NCOUNTRY int,
  @GTD varchar(23),  @OUR_ID smallint, @WEIGHT decimal(12, 3), @OnlyMinP bit=0, 
  @FirstNakl INT, @CountryID int,  @ProducerID int, @TomorrowSell decimal(10,3), @Rest decimal(10,3)

begin
  set @kolError=0;
  BEGIN TRANSACTION;
  set @ND = dbo.today();
  set @tm = convert(varchar(8), getdate(), 108);
  if isnull(@SerialNom,0)=0 set @SerialNom=(SELECT max(isnull(SerialNom,0)) from Izmen)+1;
  
  
  /********************************************************************
  *    ТРАНСМУТАЦИЯ. Отличие от других веток: используются параметры  *
  *    @TransmDec, @TransmAdd, @NewNcod                               *
  ********************************************************************/  
  if (@Act='Тран')  begin
    select 
      @Hitag=Hitag, @Ncod=ncod, @Ncom=Ncom, @Price=Price, 
      @Cost=Cost, @Sklad=Sklad,  @Dck=dck
    from TDVI where id=@ID;
    set @Pin=(select Pin from Def where Ncod=@Ncod);
    select @minp=minp, @mpu=mpu from nomen where hitag=@NewHitag

    set @NewId=(select max(id) from tdVi)+1;

    insert into tdIZ(act,id,newid,kol,newkol,price,newprice,cost,newcost, SerialNom,
      ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag)
    values(@Act,@id,@newid,@TransmDec,@TransmAdd,@price,@newprice,@cost,@newcost, @SerialNom,
      @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@dck, @hitag, @newhitag);
    if @@Error<>0 set @KolError=@KolError + 1
    
    insert into Izmen(act,id,newid,kol,newkol,price,newprice,cost,newcost,SerialNom,
      ncod,ncom,op,sklad,newsklad,remark,printed,comp,dck, hitag, newhitag, Pin)
    values('Tran',@id,@newid,@TransmDec,@TransmAdd,@price,@newprice,@cost,@newcost,@SerialNom,
      @ncod,@ncom,@op,@sklad,@newsklad,@remark,0,@comp,@dck, @hitag, @newhitag, @Pin);
    if @@Error<>0 set @KolError=@KolError + 2
    
    insert into tdVi(nd,id,startid,ncom,ncod,datepost,price,start,startthis,
      hitag, sklad, cost, nalog5, minp, mpu, sert_id, rang, morn, sell, isprav,
      remov, bad, dater, srokh, country, rezerv, units, locked, ncountry,
      gtd, vitr, our_id, weight,dck, Pin)
    select
      dbo.today() as ND,
      @newid, v.startid, @Ncom, @NewNcod, datepost, @NewPrice, 0,0,
      @NewHitag, @NewSklad, @NewCost, 0, @MinP, @Mpu, v.Sert_Id, '5', 0,0,@TransmAdd,
      0,0,v.dater, v.srokh, v.country, 0, v.units, v.locked, v.ncountry,
      v.gtd,0,v.our_id, @Weight, @Dck, @Pin
    from tdvi v
    where v.ID=@ID;
    if @@Error<>0 set @KolError=@KolError + 4
    
    update tdvi set Isprav=isnull(Isprav,0)-@TransmDec where id=@id;
    if @@Error<>0 set @KolError=@KolError + 8
  end;
  if @KolError=0 Commit; else Rollback;
     
end;