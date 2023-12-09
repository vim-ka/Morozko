CREATE PROCEDURE [NearLogistic].MarshUpdate_del
  @Dist float,
  @TimePlan char(5),
  @TimeStart char(5),
  @TimeFinish char(5),
  @TimePhoneCall char(5),
  @N_Driver smallint,
  @N_Sped smallint,
  @V_ID int,
  @FuelMark varchar(10),
  @FuelCode varchar(10),
  @Fuel0 float,
  @Fuel1 float,
  @FuelAdd float,
  @Km0 float,
  @Km1 float,
  @TimeGo datetime,
  @TimeBack datetime,
  @Bill money,
  @Away bit,
  @V_idTr int,
  @RtnTovFlg bit,
  @MoneyBack money,
  @drId int,
  @Remark varchar(100),
  @dopWeight float,
  @TmCallDrv char(5),
  @nlTariffParamsIDDrv int,
  @nlTariffParamsIDSpd int,
  @Direction varchar(100),
  @SpedDrID int,
  @SelfShip bit,
  @Peni float,
  @WayPay money,
  @VetPay money,
  @mhid int,
  @CalcDist float=0.0,
  @MStatus int=0
as
begin
  if @TimeGo = 0 set @TimeGo = null;
  if @TimeBack = 0 set @TimeBack = null;
  --set @mhid = (select Mhid from Marsh where ND=@ND and Marsh=@Marsh);
  if (@mhid is null)
    insert into Marsh(Driver,Dist,
      TimePlan,TimeStart,TimeFinish,
      N_Driver, N_Sped, 
      FuelMark,FuelCode,Fuel0,Fuel1,FuelAdd,Km0,Km1,V_ID, TimeGo, TimeBack, Peni, WayPay, VetPay, CalcDist, MStatus)
    values(@Direction,@Dist,
      @TimePlan,@TimeStart,@TimeFinish,
      @N_Driver, @N_Sped, 
      @FuelMark,@FuelCode,@Fuel0,@Fuel1,@FuelAdd,@Km0,@Km1,@V_ID,
      @TimeGo, @TimeBack, @Peni, @WayPay, @VetPay, @CalcDist, @MStatus);
  else
    UPDATE dbo.Marsh  
    SET 
      Driver = @Direction,
      Dist = @Dist,
      TimePlan = @TimePlan,
      TimeStart = @TimeStart,
      TimeFinish = @TimeFinish,
      TimePhoneCall = @TimePhoneCall,
      N_Driver = @N_Driver,
      N_Sped = @N_Sped,
      V_ID = @V_ID,
      FuelMark = @FuelMark,
      FuelCode = @FuelCode,
      Fuel0 = @Fuel0,
      Fuel1 = @Fuel1,
      FuelAdd = @FuelAdd,
      Km0 = @Km0,
      Km1 = @Km1,
      TimeGo = @TimeGo,
      TimeBack = @TimeBack,
      Bill = @Bill,
      Away = @Away,
      V_idTr = @V_idTr,
      RtnTovFlg = @RtnTovFlg,
      MoneyBack = @MoneyBack,
      drId = @drId,
      Remark = @Remark,
      dopWeight = @dopWeight,
      TmCallDrv = @TmCallDrv,
      nlTariffParamsIDDrv = @nlTariffParamsIDDrv,
      nlTariffParamsIDSpd = @nlTariffParamsIDSpd,
      Direction = @Direction,
      SpedDrID = @SpedDrID,
      SelfShip = @SelfShip,
      Peni = @Peni,
      WayPay = @WayPay,
      VetPay =@VetPay,
      CalcDist=@CalcDist,
      MStatus=@MStatus
   WHERE mhid = @mhid;
  
  exec [NearLogistic].TariffFind @mhid, 1 
    
end;