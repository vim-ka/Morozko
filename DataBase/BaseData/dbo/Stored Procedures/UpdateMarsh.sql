CREATE  procedure [dbo].[UpdateMarsh]
  @ND datetime, @marsh int, @Weight float, @BoxQty float,@Driver varchar(80)='',
  @Sped varchar(50), @Done tinyint, @Closed tinyint,
  @Dist float, @DistPay money,
  @Sp money, @SpedPay money,
  @Hours float, @HoursPay money, @Marja money,
  @Minuts tinyint, @Dots int, @DotsPay money,
  @TimePlan char(5), @TimeStart char(5), @TimeFinish char(5),
  @N_Driver smallint/*код в таблице Drivers*/,
  @N_Sped smallint, @Vehicle varchar(10), @MaxWeight int,
  @FuelMark varchar(10), @FuelCode varchar(10),
  @Fuel0 float, @Fuel1 float, @FuelAdd float,
  @Km0 float, @Km1 float, @V_ID int, @TimeGo datetime, @TimeBack datetime, @Bill money,
  @DrvPay money, @CityFLG numeric(1,0), @Stockman int=0, @WayPay money=0, 
  @VetPay money=0, @BackTara int=0, @Away bit=0,
  @NotifyDrvTime varchar(5)='', 
  @RatedArrivalTime varchar(5)='',
  @mState int=0, @NegProfit bit,
  @V_idTr int=0,
  @TimePhoneCall varchar(5)='',
  @RtnTovFlg bit=0,
  @MoneyBack bit=0,
  @DepId int=0,
  @CalcDist int=0,
  @OP int=0,
  @SpedDrID int=0,
  @Direction varchar(80)=''
as
declare @mhid int,@P_id int;
declare @ReadyDT datetime;
declare @AwayTime datetime;

begin
 -- if @Timego=0 set @Timego=null;
  -- if @TimeBack=0 set @TimeBack=null;
  set @mhid = (select Mhid from Marsh where ND=@ND and Marsh=@Marsh);
  if @Done=0 set @ReadyDT=null; else set @ReadyDT=GETDATE();
  if @Away=0 set @AwayTime=null; else set @AwayTime=GETDATE();
  set @P_id=(select P_id from Drivers where drId=@N_Driver)
 /*   if (@mhid is null)
    insert into Marsh(ND,Marsh,Weight,BoxQty,Driver,Sped,Done,Closed,Dist,
	  DistPay,Dohod,SpedPay,LgsId, Hours, HoursPay, Marja, Minuts, Dots, DotsPay, TimePlan,TimeStart,TimeFinish,
      N_Driver, N_Sped, Vehicle, MaxWeight,
      FuelMark,FuelCode,Fuel0,Fuel1,FuelAdd,Km0,Km1,V_ID, TimeGo, TimeBack,
       ReadyDt,Bill, DrvPay,CityFLG,Stockman,WayPay,VetPay,BackTara, Away, AwayTime,
       NotifyDrvTime, RatedArrivalTime,mState)
    values(@ND,@Marsh,@Weight,@BoxQty,@Driver,@Sped,@Done,@Closed,@Dist,@DistPay,@Dohod,@SpedPay,@LgsId,
      @Hours, @HoursPay, @Marja, @Minuts, @Dots, @DotsPay, @TimePlan,@TimeStart,@TimeFinish,
      @N_Driver, @N_Sped, @Vehicle, @MaxWeight, @FuelMark,@FuelCode,@Fuel0,@Fuel1,@FuelAdd,@Km0,@Km1,@V_ID,
      @TimeGo, @TimeBack, @ReadyDt, @Bill, @DrvPay, @CityFLG, @Stockman, @WayPay, @VetPay, @BackTara, @Away, @AwayTime,
      @NotifyDrvTime, @RatedArrivalTime,0);
  else begin*/
 if (@mhid is not null) and (@ND is not null) and (@Marsh is not null)
 begin
    update Marsh set Weight=@weight,BoxQty=@BoxQty,Driver=@Driver,Sped=@Sped,
      Done=@Done,Closed=@Closed,Dist=@Dist,DistPay=@DistPay, Dohod=@Sp,
      SpedPay=@SpedPay, 
      Hours=@Hours, HoursPay=@hoursPay, Marja=@marja,
      Minuts=@Minuts, Dots=@Dots, DotsPay=@DotsPay,
      TimePlan=@TimePlan, TimeStart=@TimeStart, TimeFinish=@TimeFinish,
      N_Driver=IsNull(@P_id,0), N_Sped=@N_Sped, Vehicle=@Vehicle, MaxWeight=@MaxWeight,
      FuelMark=@FuelMark, FuelCode=@Fuelcode,
      Fuel0=@Fuel0, Fuel1=@Fuel1, FuelAdd=@FuelAdd,
      Km0=@Km0, Km1=@km1, V_ID=@V_ID,
      TimeGo=@TimeGo, TimeBack=@TimeBack, ReadyDt=@ReadyDT,
      Bill=@Bill, DrvPay=@DrvPay , /*CityFLG=@CityFLG,*/
      Stockman=@Stockman,
      WayPay=@WayPay,
      VetPay=@VetPay,
      BackTara=@BackTara,
      Away=@Away,
      NotifyDrvTime=@NotifyDrvTime,
      RatedArrivalTime=@RatedArrivalTime,
      mState=@mState,
      NegProfit=@NegProfit, 
      V_idTr=@V_idTr,
      TimePhoneCall=@TimePhoneCall,
      RtnTovFlg=@RtnTovFlg,
      MoneyBack=@MoneyBack, 
      drId=@N_Driver,
      depId=@DepId,
      CalcDist=@CalcDist,
      SpedDrID=@SpedDrID,
      Direction=@Direction
      where Mhid=@Mhid;
    if @Away is not null 
      update Marsh set Awaytime=@Awaytime
      where Mhid=@Mhid and Awaytime is null; 
       
     /* update Marsh set weight=(
               select Sum(T.AllW)as Allw from
     (select nv.DatNom,
        CASE
          when C.Netto>0 then sum(Kol*C.Netto)
          when IsNull(B.Weight,0)>0 and C.Netto=0 then Sum(Kol*B.Weight)
          when IsNull(B.Weight,0)=0 and C.Netto=0 then Sum(Kol*IsNull(D.Weight,0))
        end as AllW
      from NV join NC A on A.datnom=nv.DatNom
            left join
            (select case when Brutto>=Netto then brutto
                         else netto
                    end as Netto,hitag from Nomen)C on C.hitag=nv.hitag 
            outer apply
            (select id,weight from tdvi where id=nv.TekID) B
            outer apply
            (select id,weight from visual where id=nv.TekID) D
            
      where (A.Sp>0 or A.actn=1) and A.ND=@ND and A.marsh=@Marsh
      group by nv.DatNom,C.Netto,B.Weight,D.Weight) T)
            where ND=@ND and marsh=@Marsh*/
 end;
 -- end;
 -- update Marsh set TimeBack=null where TimeBack<'20000101';

end;