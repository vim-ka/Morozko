CREATE PROCEDURE NearLogistic.ListPayCreate @ttID int, @Op int, @Rec bit /*устарел*/, @ListNo int=0
AS
BEGIN
  declare @VedOpl int, @countRec int, @DurationHr decimal(7,2), @ND1 dateTime, @ND2 datetime, @type varchar(3), @Rem varchar(60), @NDTod datetime
  
  declare @DotsBasePlan int, @Dot2NetDot float, @isBonus bit 

  set @NDTod=dbo.today();

  select @DotsBasePlan=cast(Value as int)
  from [NearLogistic].nlConfig
  where Param='DotsBasePlan'

  select @Dot2NetDot=cast(Value as float)
  from [NearLogistic].nlConfig
  where Param='Dot2NetDot'

if @ListNo = 0 -- создаем новую ведомость
begin

  if @ttID not in (5)
  begin
    select
    case when m.ScanND is null or m.LockBill=1 /*and @ttID in (1,2,3,6) or v.crid=164*/ then cast(0 as bit) else cast(1 as bit) end as Met,
    case when @ttID=4 then 2
         when @ttID=5 then 3
         else 1 end as Num,
    m.mhid,
    m.nd,
    m.Marsh,
    NearLogistic.GetMarshRegString(m.mhid)+' '+isnull(m.Direction,'')+' '+v.Model+' '+v.RegNom  as Name,
    r.Fio as Driver,
    rs.Fio as Speditor,
    pd.Pay1Km*m.Dist as Pay1Km,
    pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0) as Pay1Dot,
    pd.Pay1Kg*(m.[Weight]+m.dopWeight) as Pay1Kg,
    pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0) as Pay1Hour,
    pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0)) as Pay1DotNet,
    pd.Pay1DotOver*(case when m.Dots>=25 then m.Dots-25 else 0 end) as Pay1DotOver,
    pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)/*+iif(@ttID=2,[NearLogistic].fnCrutch(m.mhid,1,0),0)*/ as PayAllDot,
    pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end) as PayAllDotOver,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0) as Rate0Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0) as Rate1Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0) as Rate2Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0) as Rate3Rank,
    pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) as Trailer,
    pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) ) as Bonus,

    t.TariffName as Tariff,
    c.crID,
    c.crName,
    m.Dist as CalcDist,
    (m.[Weight]+m.dopWeight) as Weight,
    m.Dots as Dots,
    m.ScanND,
    cast(pd.Pay1Km*m.Dist+
    pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
    pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
    pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
    pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
    pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
    pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+/*iif(@ttID=2,[NearLogistic].fnCrutch(m.mhid,1,0),0)+*/
    pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0)+
    pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
    pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) )   as money)-m.Peni as sm,
    t.ttID,
    m.ListNo,
    y.TariffType,
    p.ND as ListND,
    iif(t.ttID=4,0.0, isnull(m.VetPay,0)+isnull(m.WayPay,0)) as OtherPlata,
    case when t.ttID in (1,4,5) then
     'Серия '+IsNull(r.PaspSeries,'')+' №'+IsNull(r.PaspNom,'')+
           ' Кем выдан: '+IsNull(r.PaspV,'')+' Дата выдачи '+
           IsNull(cast(r.PaspDateV as varchar(10)),'')
         else
     'Расчетный счет '+c.crRs+'   ИНН '+c.CrInn    
         end as Description,
    cast(0 as bit) as SecondDriver,
    r.drId,
    rs.drid [speddrid],
    m.lock_remark  
    into #Temp
    from  Marsh m join NearLogistic.nlTariffParams pd on m.nlTariffParamsIDDrv=pd.nlTariffParamsID
                  join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                  join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
                  join NearLogistic.nlTariffType y on t.ttID=y.ttID
                  left join Drivers r on m.drId=r.drId
                  left join Person pr on r.P_ID=pr.P_ID
                  left join Drivers rs on m.SpeddrId=rs.drId
                  left join 
                  (select c.nd, m.marsh, count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) as DotsNet
                   from nc c join defcontract f on c.dck=f.dck
                         join def d on c.b_id=d.pin
                         join marsh m on c.mhID = m.mhid   --c.nd=m.nd and c.marsh=m.marsh
                         join agentlist a on f.ag_id=a.ag_id
                   where a.depid in (3,26)
                   group by c.nd, m.marsh) n on n.nd=m.nd and n.marsh=m.marsh                 
                   
                 /* (select c.nd, c.marsh,count(distinct c.b_id) as DotsNet
                  from nc c join def d on c.b_id=d.pin
                 where d.master>0 group by c.nd, c.marsh) n on n.nd=m.nd and n.marsh=m.marsh*/
                 cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.drID=m.drId) ms
                  join Vehicle v on v.v_id=m.v_id
                  join Carriers c on c.crID=v.crID
                  left join NearLogistic.nlListPay p on p.ListNo=m.ListNo
    where  t.ttID=@ttID
           and (m.ListNo = 0 and t.ttID<>5) --or (isnull(m.ListNoSped,0) = 0 and t.ttID=5))
           and ((m.nd>='20151101' and t.ttID<>4) or (m.nd>='20170205' and /*m.nd<=DATEADD(d,-8,@NDTod) and*/ t.ttID=4 and pr.DepID<>45))
           and m.MStatus>=2 and m.VedNo=0 and m.DelivCancel=0
           
    
    select * from #Temp       
    order by case when @ttID in (4,5) then Driver
                  when @ttID=5 then Speditor
                  else crName end, nd, marsh
  END
  else
  if @ttID=5

    select
    case when m.ScanND is null /*and @ttID in (1,2,3,6)*/ then cast(0 as bit) else cast(1 as bit) end as Met,
    case when @ttID=4 then 2
         when @ttID=5 then 3
         else 1 end as Num,
    m.mhid,
    m.nd,
    m.Marsh,
    NearLogistic.GetMarshRegString(m.mhid)+' '+isnull(m.Direction,'')+' '+v.Model+' '+v.RegNom as Name,
    r.Fio as Driver,
    rs.Fio as Speditor,
    pd.Pay1Km*m.Dist as Pay1Km,
    iif(m.SpeddrId in (796,1863),0, pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)) as Pay1Dot,
    pd.Pay1Kg*(m.[Weight]+m.dopWeight) as Pay1Kg,
    pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0) as Pay1Hour,
    iif(m.SpeddrId in (796,1863),0,pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))) as Pay1DotNet,
    pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end) as Pay1DotOver,
    pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end) as PayAllDot,
    pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end) as PayAllDotOver,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0) as Rate0Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0) as Rate1Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0) as Rate2Rank,
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0) as Rate3Rank,
    pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) as Trailer,
    pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) ) as Bonus,
    
    t.TariffName as Tariff,
    c.crID,
    c.crName,
    m.Dist as CalcDist,
    (m.[Weight]+m.dopWeight) as Weight,
    m.Dots as Dots,
    m.ScanND,
    cast(pd.Pay1Km*m.Dist+
    iif(m.SpeddrId in (796,1863),0,pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0))+
    pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
    pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
    iif(m.SpeddrId in (796,1863),0,pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0)))+
    pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
    pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
    pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0)+
    [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0)+
    pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
    pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) )  as money)-m.Peni as sm,
    t.ttID,
    m.ListNo,
    y.TariffType,
    p.ND as ListND,
    0.0 as OtherPlata,
    case when t.ttID in (1,4,5) then
     'Серия '+IsNull(r.PaspSeries,'')+' №'+IsNull(r.PaspNom,'')+
           ' Кем выдан: '+IsNull(r.PaspV,'')+' Дата выдачи '+
           IsNull(cast(r.PaspDateV as varchar(10)),'')
         else
     'Расчетный счет '+c.crRs+'   ИНН '+c.CrInn    
         end as Description,
    CAST(0 as bit) as SecondDriver,
    m.drId,
    m.speddrid,
    m.lock_remark 
    from  Marsh m join NearLogistic.nlTariffParams pd on m.nlTariffParamsIDSpd=pd.nlTariffParamsID
                  join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                  join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
                  join NearLogistic.nlTariffType y on t.ttID=y.ttID
                  left join Drivers r on m.drId=r.drId
                  join Drivers rs on m.SpeddrId=rs.drId
                  left join 
                  (select c.nd, m.marsh, count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) as DotsNet
                   from nc c join defcontract f on c.dck=f.dck
                         join def d on c.b_id=d.pin
                         join marsh m on  c.mhID = m.mhid    --c.nd=m.nd and c.marsh=m.marsh
                         join agentlist a on f.ag_id=a.ag_id
                   where a.depid in (3,26)
                   group by c.nd, m.marsh) n on n.nd=m.nd and n.marsh=m.marsh
                 cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.SpeddrId=m.SpeddrId) ms
                  join Vehicle v on v.v_id=m.v_id
                  join Carriers c on c.crID=v.crID
                  left join NearLogistic.nlListPay p on p.ListNo=m.ListNo
    where  t.ttID=@ttID
           and isnull(m.ListNoSped,0) = 0 
           and m.nd>='20170306' --and m.nd<='20170319' 
           and m.MStatus>=2 
           and m.DelivCancel=0
           and isnull(rs.trId,0) not in (16)
    order by case when @ttID=4 then r.FIO
                  when @ttID=5 then rs.FIO
                  else c.crName end, m.nd, m.marsh 

end

else -- Читаем уже сохраненную

begin
 -- if @ttID not in (4,5) 
 
 set @ttID=(select ttID from [NearLogistic].nlListPay where ListNo=@ListNo)
  
  select
  CAST(1 as bit) as Met,
  case when @ttID=4 then 2
       when @ttID=5 then 3
       else 1 end as Num,
  m.mhid,
  m.nd,
  m.Marsh,
  NearLogistic.GetMarshRegString(m.mhid)+' '+isnull(m.Direction,'')+' '+v.Model+' '+v.RegNom as Name,
  r.Fio as Driver,
  isnull(rs.Fio,'') as Speditor,
  pd.Pay1Km*m.Dist as Pay1Km,
  pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0) as Pay1Dot,
  pd.Pay1Kg*(m.[Weight]+m.dopWeight) as Pay1Kg,
  pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0) as Pay1Hour,
  pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0)) as Pay1DotNet,
  pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end) as Pay1DotOver,
  pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)/*+iif(@ttID=2,[NearLogistic].fnCrutch(m.mhid,1,0),0)*/ as PayAllDot,
  pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end) as PayAllDotOver,
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0) as Rate0Rank,
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0) as Rate1Rank,
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0) as Rate2Rank,
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0) as Rate3Rank,
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) as Trailer,
  pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) ) as Bonus,
  t.TariffName as Tariff,
  c.crID,
  c.crName,
  m.Dist as CalcDist,
  (m.[Weight]+m.dopWeight) as Weight,
  m.Dots as Dots,
  m.ScanND,
  cast(pd.Pay1Km*m.Dist+
  pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
  pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
  pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
  pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
  pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+/*iif(@ttID=2,[NearLogistic].fnCrutch(m.mhid,1,0),0)+*/
  pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
  pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1,0)+
  [NearLogistic].WorkShift(iif(isnull(m.dist,0)<>0,m.Dist,0))*pd.Rate0Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1,0)+
  pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) +
  pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) )  as money)-m.Peni as sm,
  t.ttID,
  m.ListNo,
  y.TariffType,
  p.ND as ListND,
  isnull(m.VetPay,0)+isnull(m.WayPay,0) as OtherPlata,
  case when t.ttID in (1,4,5) then
   'Серия '+IsNull(r.PaspSeries,'')+' №'+IsNull(r.PaspNom,'')+
         ' Кем выдан: '+IsNull(r.PaspV,'')+' Дата выдачи '+
         IsNull(convert(varchar(10),r.PaspDateV,104),'')
       else
   'Расчетный счет '+c.crRs+'   ИНН '+c.CrInn    
       end as Description,
   CAST(m.SecondDriver as bit) as SecondDriver,
    m.drId,
    m.speddrid,
    '' AS lock_remark        
  
  from  NearLogistic.nlListPayDet m join NearLogistic.nlTariffParams pd on m.nlTariffParamsID=pd.nlTariffParamsID
                                    join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                                    join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID
                                    join NearLogistic.nlTariffType y on t.ttID=y.ttID
                                    left join Drivers r on m.drId=r.drId
                                    left join Drivers rs on m.SpeddrId=rs.drId
                                    left join 
                                    (select c.nd, m.marsh, count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) as DotsNet
                                     from nc c join defcontract f on c.dck=f.dck
                                     join def d on c.b_id=d.pin
                                     join marsh m on c.mhID = m.mhid       --c.nd=m.nd and c.marsh=m.marsh
                                     join agentlist a on f.ag_id=a.ag_id
                                     where a.depid in (3,26)
                                     group by c.nd, m.marsh) n on n.nd=m.nd and n.marsh=m.marsh
                                    /*(select c.nd, c.marsh,count(distinct c.b_id) as DotsNet
                                    from nc c join def d on c.b_id=d.pin
                                    where d.master>0 group by c.nd, c.marsh) n on n.nd=m.nd and n.marsh=m.marsh*/
                                    cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.drID=m.drId) ms
                                    join Vehicle v on v.v_id=m.v_id
                                    join Carriers c on c.crID=v.crID
                                    left join NearLogistic.nlListPay p on p.ListNo=m.ListNo
  where t.ttID=@ttID and m.ListNo=@ListNo 
  order by case when @ttID=4 then r.FIO
                when @ttID=5 then rs.FIO
                else c.crName end, m.nd, m.marsh
 
   
end 
  
END