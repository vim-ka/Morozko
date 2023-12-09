 -- Корреция данных в IZMEN по заданной строке
CREATE procedure dbo.CorrectIzmen @izmid INT 
AS
declare @NewID int, @StartID int, @DatePost datetime,
 @MinP int, @Mpu int, @Sert_ID int, @DateR datetime, @SrokH datetime,
 @Country varchar(50), @Units varchar(3), @Ncountry int, @Gtd varchar(100),
 @Our_ID int, @MeasID smallint,@OnlyMinP bit,@AddrID int,@ProducerID int,
 @CountryID int,@wsID smallint, @safeCust bit,@PinOwner int, @DCKOwner int, 
 @pin int, @OldID int, @OldCost decimal(15,5);
BEGIN

  -- Читаем все что можно из табл. VISUAL:
  select @StartID=V.StartID, @DatePost=v.datepost, @Minp=V.MinP, @Mpu=V.Mpu,
    @Sert_ID=V.sert_id, @DateR=v.dater, @Srokh=V.Srokh, @Country=V.country,
    @Units=V.units, @Ncountry=V.Ncountry, @Gtd=V.Gtd,@Our_ID=V.Our_ID, @MeasID=V.MeasID,
    @ProducerID=v.ProducerID,@CountryID=v.CountryID,
    @safeCust=1, @pin=v.Pin
  from 
    Visual V 
    inner join Izmen i on i.id=V.id 
  where i.izmid=@izmid;

  select @OldID=newid, @OldCost=newcost from Izmen where izmid=@izmid;


  if isnull(@StartID,0)>0 -- нашлось что-то?
  BEGIN
    -- Сначала добавляем новую строку в TDVI, часть данных берем из IZMEN:
    INSERT INTO dbo.tdVi (ND,STARTID,NCOM,NCOD,DATEPOST,PRICE,START,STARTTHIS,
      HITAG,SKLAD,COST,NALOG5,MINP,MPU,SERT_ID,RANG,MORN,SELL,ISPRAV,
      REMOV,BAD,DATER, SROKH,COUNTRY,REZERV,UNITS,LOCKED,NCOUNTRY,
      GTD,VITR,OUR_ID,WEIGHT,SaveDate,MeasId, OnlyMinP,AddrID,DCK, 
      ProducerID, CountryID,wsID,safeCust,Price_old,LockID,PinOwner,DCKOwner,pin)
    SELECT
      i.nd, @StartID, i.Ncom, i.ncod, @DatePost, i.newprice, 0, 0,
      i.NewHitag, i.NewSklad, i.NewCost, 0, @MinP,@Mpu,@Sert_ID, '5', 0,0, 0, -- i.NewKol-i.kol as Isprav,
      0, 0, @DateR, @Srokh, @Country, 0, @Units, 0, @Ncountry,
      @Gtd, 0, @Our_ID, i.NewWeight, i.nd, @MeasID,0,null,i.DCK,
      @ProducerID, @CountryID,null,@safeCust, i.NewPrice,0,null,null,@pin
    from Izmen i
    where izmid=@izmid;

    set @NewID=SCOPE_IDENTITY();  

    update Izmen set NewID=@NewID where izmid=@izmid;

    update NV set TekID=@NewID where TekID=@OldID and abs(Cost-@OldCost)<=0.01;
  end

END