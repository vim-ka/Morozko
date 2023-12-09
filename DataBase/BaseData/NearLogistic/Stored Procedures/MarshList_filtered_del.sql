CREATE PROCEDURE [NearLogistic].MarshList_filtered_del @ND datetime
AS
BEGIN
select  msh.Nd,
    msh.marsh,
        cast(Done as bit) [Done], 
    msh.VedNabPrinted,
        Weight,
        SpedDrID as Sped,
        msh.Direction as Napravl,
        msh.drid/*N_Driver*/ as Driver,
        Dr.Fio as DriverName,
        msh.V_id as Car,
        C.CarName as CarName,
        ( select count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) 
          from nc c 
      join def d on c.b_id=d.pin
          where c.nd=msh.nd and c.marsh=msh.marsh
    ) as Dots,
        Dohod as SumZgruz,
        Marja as Nac,
        Marja - [NearLogistic].Marsh1OtherExpense(msh.mhid) as Dohod,
        [NearLogistic].Marsh1CalcFact(msh.mhid) as Transp,
        msh.Marja - [NearLogistic].Marsh1CalcFact(msh.mhid) - [NearLogistic].Marsh1OtherExpense(msh.mhid) as Profit,       
        '' as reg,
        CalcDist as Dist,
    DistPay,
    DotsPay,
    SpedPay,
    DrvPay,
    0 as tip,
    0 as MarshOld,
        G.Fio as SpedName,
        WayPay,
        VetPAy,
        backTara,
        mState,
        NegProfit,
        V_idTr,
        case
          when IsNull(V_idTr,0)>0 then 1 else 0
        end as Trailer,
        case
          when (TimeGo='0:00:00' or TimeGo is null) then '' else dbo.InDate(TimeGo)
        end as DateGo, 
        case 
          when (TimeGo='0:00:00' or TimeGo is null)then '00:00'else dbo.InTime(TimeGo)  
        end as TimeGo,
        TimePlan,
    TimeStart,
    TimeFinish,
        case
          when (Weight<=500) then  dbo.InTime(cast(40/60.0/24.0 as datetime))
          when (Weight>500) and (Weight<=1000) then dbo.InTime(cast(60/60.0/24.0 as datetime))
          when (Weight>1000) and (Weight<=1500) then dbo.InTime(cast(80/60.0/24.0 as datetime))
          when (Weight>1500) and(Weight<=2000) then dbo.InTime(cast(90/60.0/24.0 as datetime))
          when (Weight>2000) and(Weight<=3500) then dbo.InTime(cast(110/60.0/24.0 as datetime))
          when (Weight>3500) then dbo.InTime(cast(120/60.0/24.0 as Datetime))
        end as TimeCheck,
        case
          when (TimeBack='0:00:00' or TimeBack is null) then '' else dbo.InDate(TimeBack) 
        end as DateBack, 
        case 
          when (TimeBack='0:00:00' or TimeBack is null) then '00:00' else dbo.InTime(TimeBack) 
        end as TimeBack,
        RatedArrivalTime,
    FuelMark,
    FuelCode,
    Fuel0,
    Fuel1,
    FuelAdd,
    Km0,
    Km1,
        Bill,
    away,
        TimePhoneCall as TmPhoneCall, 
    IsNull(RtnTovFlg,0) as RtnTovFlg,
        IsNull(MoneyBack,0) as MoneyBack,msh.DepId,Dist as FactDist,DName,CityFLG,C.VehType,
        E.TypeN,
        msh.mhId,
        0 as CountBPos,
        Stockman,
        GrMan,
        Remark,
        N_Driver as P_id,
        (msh.drID) as Drv,
        case
         when IsNull((select COUNT(a.mhid)as cSK from MarshSkMan a where a.mhid=msh.mhid and a.spk>0),0)>0 then 1 else 0
        end as SkMan,
        DelivCancel,
        IsNull(R.cntCD,0) as DelivC,
        case
          when (S.physPerson=0) and (C.crId>0) and (C.crId<>7) and (S.NDS=0) then 1    /* C.crid<>7 это авто морозко */
          else  case 
         when (S.physPerson=0) and (C.crId>0) and (C.crid<>7) and (S.NDS=1) then 2 
              else 0
            end
        end as IpPerevoz,
        Description,        
        (select Count(s.brNo)as brNo from MarshSertif s where s.mhid=msh.mhid) as Sertif,        
        IsNull(dopWeight,0) as dopWeight,
    ScanNd,
    PercWorkPay,
    Peni,
    VedNo,
        IsNull(TmCallDrv,'00:00') as TmCallDrv,
    0 as LgstType,        
        case
          when exists(select j.mjid from MarshJob j where j.mhID=msh.mhid) then cast(1 as bit) else cast(0 as bit)
        end as Jobs,
        msh.nlTariffParamsIDDrv,
        msh.nlTariffParamsIDSpd,
        msh.SpedDrID, 
        Dr.Phone,
        isnull(C.nlVehCapacityID,0) as nlVehCapacityID,
        MStatus
from Marsh  msh
     left join (select r.Fio,r.drid,r.LgstType,r.Phone from Drivers r ) Dr on Dr.drID=msh.drid 
     left join (select r.Fio, r.drid from Drivers r) G on G.drid=msh.SpedDrID
     left join (select Model+' Рег. ном. "'+RegNom+'"' as CarName,V_id,VehType,crid,nlVehCapacityID from Vehicle) C on C.V_id=msh.V_id  
     left join (select crid,physPerson,NDS from Carriers) S on S.crid=C.crid 
     left join (select s.DName,s.DepId from Deps s) D on  D.DepID=msh.Depid
     left join (select cast(VehType as varchar)+' ('+Description+')' as TypeN,vehType from VehType)E on E.VehType=C.VehType           
     left join (select count(datNom) as cntCD, Marsh from NC where Nd=@ND and DelivCancel=1 group by marsh)R on R.marsh=msh.marsh
where nd=@ND
order by Marsh

END