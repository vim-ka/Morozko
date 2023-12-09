CREATE PROCEDURE dbo.MarshList @ND datetime
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

select msh.Nd,msh.marsh,
       Done, msh.VedNabPrinted,
       Weight,--N_Sped as Sped,
       SpedDrID as Sped,
       msh.Direction as Napravl,
       msh.drid/*N_Driver*/ as Driver,
       Dr.Fio as DriverName,
       msh.V_id as Car,
       C.CarName as CarName,
       Dots,
       Dohod as SumZgruz,
       Marja as Nac,
       Marja - [NearLogistic].Marsh1OtherExpense(msh.mhid) as Dohod,
       
       
      /* round(sum(0.104*(v.Price-v.Cost)*v.kol),2) as OplTrud,
       round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2) as PayStor,
       round(sum(case when e.dfID=7 then 0 else 0.05*v.Cost*v.kol end),2) as AdmRash,
       round(sum((case when isnull(d.WEIGHT,0)<>0 then d.weight*v.kol else n.netto*v.kol end)*g.Cost1kgDeliv),2)*/
       
       /*case
         when DotsPay>100 and cityflg=3 then
            (Marja-(Dohod-Marja)*0.2)-(CalcDist*DistPay+DrvPay*(weight+dopWeight)+DotsPay+SpedPay)
         when (S.physPerson=0) and (C.crId>0) and (C.crid<>7) and (cityflg=3) and (Dots>25) then
            (Marja-(Dohod-Marja)*0.2)-(CalcDist*DistPay+DrvPay*(weight+dopWeight)+
             25*DotsPay+(Dots-25)*2*DotsPay+SpedPay+IsNull(PercWorkPay,0))
         else
            (Marja-(Dohod-Marja)*0.2)-(CalcDist*DistPay+DrvPay*(weight+dopWeight)+Dots*DotsPay+SpedPay+IsNull(PercWorkPay,0))
       end as Profit,
       case 
          when DotsPay>100 and cityflg=3 then
            (CalcDist*DistPay+DrvPay*(weight+dopWeight)+DotsPay+SpedPay)
          when (S.physPerson=0) and (C.crId>0) and (C.crid<>7) and (cityflg=3) and (Dots>25) then
            (CalcDist*DistPay+DrvPay*(weight+dopWeight)+
             25*DotsPay+(Dots-25)*2*DotsPay+SpedPay+IsNull(PercWorkPay,0))
          else
             (CalcDist*DistPay+DrvPay*(weight+dopWeight)+Dots*DotsPay+SpedPay+IsNull(PercWorkPay,0))
       end as Transp,*/
       [NearLogistic].Marsh1CalcFact(msh.mhid) as Transp,
       msh.Marja - [NearLogistic].Marsh1CalcFact(msh.mhid) - [NearLogistic].Marsh1OtherExpense(msh.mhid) as Profit,
          
       '' as reg,
       CalcDist as Dist,DistPay,DotsPay,SpedPay,DrvPay,0 as tip,0 as MarshOld,
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
       TimePlan,TimeStart,TimeFinish,
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
       RatedArrivalTime,FuelMark,FuelCode,Fuel0,Fuel1,FuelAdd,Km0,Km1,
       Bill,away,
       --case
       --  when (B.Cjob>0) then 1 else 0
      -- end as Jobs,
       TimePhoneCall as TmPhoneCall, IsNull(RtnTovFlg,0) as RtnTovFlg,
       IsNull(MoneyBack,0) as MoneyBack,msh.DepId,Dist as FactDist,DName,CityFLG,C.VehType,
       E.TypeN,
       msh.mhId,
        --Cr.CountBPos,
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
        0 as DelivC,
        --IsNull(R.cntCD,0) as DelivC,
        case
          when (S.physPerson=0) and (C.crId>0) and (C.crId<>7) and (S.NDS=0) then 1    /* C.crid<>7 это авто морозко */
          else case when (S.physPerson=0) and (C.crId>0) and (C.crid<>7) and (S.NDS=1) then 2 
          else 0
        end
        end as IpPerevoz,
        Description,
        
        (select Count(s.brNo)as brNo from MarshSertif s where s.mhid=msh.mhid) as Sertif,
        
        IsNull(dopWeight,0) as dopWeight,ScanNd,PercWorkPay,Peni,VedNo,
        IsNull(TmCallDrv,'00:00') as TmCallDrv,0 as LgstType/*,Dr.LgstType */,
        
        case
          when exists(select j.mjid from MarshJob j where j.mhID=msh.mhid) then 1 else 0
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
--left join (select count(mjid) as CJob,mhid from MarshJob group by mhid)B on B.mhid=msh.Mhid
left join (select Model+' Рег. ном. "'+RegNom+'"' as CarName,V_id,VehType,crid,nlVehCapacityID from Vehicle) C on C.V_id=msh.V_id  
left join (select crid,physPerson,NDS from Carriers) S on S.crid=C.crid 
left join (select s.DName,s.DepId from Deps s) D on  D.DepID=msh.Depid
left join (select cast(VehType as varchar)+' ('+Description+')' as TypeN,vehType from VehType)E on E.VehType=C.VehType

--left join (select count(datNom) as cntCD, Marsh from NC where Nd=@ND and DelivCancel=1 group by marsh)R on R.marsh=msh.marsh
/*cross apply (select count(distinct pin) as CountBPos  from Def where (PosX=0 or PosY=0 or PosX is null or PosY is null) and worker<>1
            and pin in (select B_id from NC where Nd=@ND and Marsh=msh.Marsh)) Cr*/


where nd=@ND
order by Marsh



END