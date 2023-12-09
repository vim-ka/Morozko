

CREATE procedure AddTdVi_DEL @ND datetime, @ID int,  @STARTID int,
  @NCOM int,  @NCOD int,  @DATEPOST datetime,  @PRICE decimal(13, 2),
  @START decimal(12, 3),  @STARTTHIS decimal(12, 3),  @HITAG int,
  @SKLAD smallint,  @COST decimal(13, 5), 
  @MINP int,  @MPU int,  @SERT_ID int, @RANG char(1),
  @MORN decimal(12, 3),  @SELL decimal(12, 3),  
  @ISPRAV decimal(12, 3),  @REMOV decimal(12, 3),  @BAD decimal(12, 3),
  @DATER datetime,  @SROKH datetime,  @COUNTRY varchar(15), @REZERV decimal(12, 3),
  @UNITS varchar(3),  @LOCKED bit,  @NCOUNTRY int,
  @GTD varchar(23),  @OUR_ID smallint, @WEIGHT decimal(12, 3), @OnlyMinP bit=0, @DCK int=0
as
begin
  if(@dater<'19500101') set @dater=null;
  if(@srokh<'19500101') set @srokh=null;
  
  if Exists(select * from tdVi where id=@id)
    update tdVi set Morn=Morn+@Morn, Start=Start+@START, Startthis=Startthis+@StartThis where id=@id;
  else  
   insert into tdVI(ND,ID,StartId,Ncom,Ncod,DatePost,Price,Start,StartThis,Hitag,Sklad,Cost,MinP,Mpu,Sert_ID,Rang,Morn,Sell,
    Isprav,Remov,Bad,DateR,SrokH,Country,Rezerv,Units,Locked,Ncountry,Gtd,Our_ID,Weight, OnlyMinP, Dck)
   values(@ND,@ID,@StartId,@Ncom,@Ncod,@DatePost,@Price,@Start,@StartThis,@Hitag,@Sklad,@Cost,@MinP,@Mpu,@Sert_ID,@Rang,@Morn,@Sell, 
    @Isprav,@Remov,@Bad,@DateR,@SrokH,@Country,@Rezerv,@Units,@Locked,@Ncountry,@Gtd,@Our_ID,@Weight, @OnlyMinP, @Dck);  
end;