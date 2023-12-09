

create procedure AddTdviRecFromIzmen @izmid int
AS
  declare @newId INT, @id1 int, @ND datetime, @Weight decimal(10,3), @Ncom int, @Ncod int,
    @Sklad int, @Dck int, @Kol int, @Hitag int, @Price decimal(10,2), @Cost decimal(13,5)
begin

  select @Nd=Nd, @id1=NewID, @weight=NewWeight, @Ncom=Ncom, @Ncod=Ncod, @Sklad=Sklad, @Dck=Dck,
    @Kol=NewKol, @Hitag=NewHitag, @Price=NewPrice, @Cost=NewCost
  from izmen where izmid=@izmid;

  set @NewID=1+(select max(id) from tdvi);





  INSERT INTO dbo.tdVi
  (ND,ID,STARTID,NCOM,NCOD,DATEPOST,PRICE,START,STARTTHIS,HITAG,SKLAD,COST,NALOG5,MINP,MPU,SERT_ID,RANG,MORN,
    SELL,ISPRAV,REMOV,BAD,DATER,SROKH,COUNTRY,REZERV,UNITS,LOCKED,NCOUNTRY,GTD,VITR,OUR_ID,WEIGHT,SaveDate,
    MeasId,OnlyMinP,AddrID,DCK,ProducerID,CountryID,wsID,safeCust,Price_old,LockID,PinOwner,DCKOwner,pin)
  VALUES
  (
  GETDATE() -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- ND - datetime
 ,@NewID -- ID - int NOT NULL
 ,@NewID -- STARTID - int NOT NULL
 ,@NCOM
 ,@NCOD
 ,@ND --  DATEPOST - datetime
 ,@PRICE -- decimal(13, 2)
 ,0 -- START - decimal(12, 3)
 ,0 -- STARTTHIS - decimal(12, 3)
 ,0 -- HITAG - int
 ,0 -- SKLAD - smallint
 ,0 -- COST - decimal(13, 5)
 ,0 -- NALOG5 - decimal(1)
 ,0 -- MINP - int
 ,0 -- MPU - int
 ,0 -- SERT_ID - int
 ,'' -- RANG - char(1)
 ,0 -- MORN - decimal(12, 3) NOT NULL
 ,0 -- SELL - decimal(12, 3) NOT NULL
 ,0 -- ISPRAV - decimal(12, 3) NOT NULL
 ,0 -- REMOV - decimal(12, 3) NOT NULL
 ,0 -- BAD - decimal(12, 3) NOT NULL
 ,GETDATE() -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- DATER - datetime
 ,GETDATE() -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- SROKH - datetime
 ,'' -- COUNTRY - varchar(50)
 ,0 -- REZERV - decimal(12, 3)
 ,'' -- UNITS - varchar(3)
 ,0 -- LOCKED - bit
 ,0 -- NCOUNTRY - decimal(3)
 ,'' -- GTD - varchar(100)
 ,0 -- VITR - decimal(12, 3)
 ,0 -- OUR_ID - smallint
 ,0 -- WEIGHT - decimal(12, 3) NOT NULL
 ,GETDATE() -- 'YYYY-MM-DD hh:mm:ss[.nnn]'-- SaveDate - datetime
 ,0 -- MeasId - tinyint
 ,0 -- OnlyMinP - bit
 ,0 -- AddrID - int
 ,0 -- DCK - int NOT NULL
 ,0 -- ProducerID - int
 ,0 -- CountryID - int
 ,0 -- wsID - tinyint
 ,0 -- safeCust - bit
 ,0 -- Price_old - decimal(13, 2)
 ,0 -- LockID - int
 ,0 -- PinOwner - int
 ,0 -- DCKOwner - int
 ,0 -- pin - int
)
END