CREATE procedure ELoadMenager.eload_fl_tariff_compare
@marshs varchar(1000),
@nd datetime,
@type int,
@v_id int =0
as
begin
declare @DotsBasePlan int 
declare @Dot2NetDot float
--declare @delivpay money
--select [NearLogistic].Marsh1Calc(:mhid, :nlTariffParamsIDDrv, :nlTariffParamsIDSpd) as Sm


select @DotsBasePlan=cast(Value as int) from [NearLogistic].nlConfig where Param='DotsBasePlan'
select @Dot2NetDot=cast(Value as float) from [NearLogistic].nlConfig where Param='Dot2NetDot'

if object_id('tempdb..#msh') is not null drop table #msh
create table #msh (mhid int, drv int, drv_new int)
insert into #msh
select x.mhid, x.drv, d.nltariffparamsid [drv_new]
from (
select m.mhid, m.nlTariffParamsIDDrv [drv],
			 m.weight [w], iif(isnull(m.km1 - m.km0,0)<=0,m.calcdist,m.km1 - m.km0) [km],
       cast(iif(m.SpedDrID>0,1,0)as bit) [withsped]
from dbo.marsh m 
where m.marsh in (select value from string_split(@marshs, ','))
			and m.nd=@nd) x
join nearlogistic.nlvehcapacity vc on x.[w] between vc.weightmin and vc.weightmax
join nearlogistic.nltariffs t on t.ttid=@type and t.withsped=x.[withsped] and x.[km] between t.diststart and t.distend 
join nearlogistic.nltariffsdet d on d.nlvehcapacityid=vc.nlvehcapacityid and t.nltariffsid=d.nltariffsid

if object_id('tempdb..#add_marsh') is not null drop table #add_marsh

select x.mhid, x.[expense], x.[gsm], round(sum(0.104*(v.price-v.cost)*v.kol),2) [rash], cast(0 as bit) [old], x.[delivpay]
into #add_marsh
from (
	select m.mhid, isnull(v.Expense,0) [expense], m.CalcDist*isnull(v.tariff1km,0) [gsm], [NearLogistic].calculate_delivery_cost(m.mhid,0,0) [delivpay]
	from dbo.marsh m
	join dbo.vehicle v on v.v_id=m.v_id
	join #msh on #msh.mhid=m.mhid
  	) x 
join dbo.nc c on c.mhid=x.mhid
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom    
group by x.mhid, x.[expense], x.[gsm], x.[delivpay]

if @v_id>0 or @type>0
insert into #add_marsh
select x.mhid, x.[expense], x.[gsm], round(sum(0.104*(v.price-v.cost)*v.kol),2) [rash], cast(1 as bit) [old], x.[delivpay]
from (
	select m.mhid, isnull(v.Expense,0) [expense], m.CalcDist*isnull(v.tariff1km,0) [gsm], [NearLogistic].calculate_delivery_cost(m.mhid,@v_id,@type) [delivpay]
	from dbo.marsh m
	join dbo.vehicle v on v.v_id=iif(@v_id=0,m.v_id,@v_id)
	join #msh on #msh.mhid=m.mhid
  	) x 
join dbo.nc c on c.mhid=x.mhid
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom    
group by x.mhid, x.[expense], x.[gsm], x.[delivpay]

select 	m.nd [Дата], m.marsh [Маршрут], t.tariffname [Тариф], iif(isnull(m.km1 - m.km0,0)<=0,m.calcdist,m.km1 - m.km0) [Пробег] ,m.weight [Масса], m.Dots [Точек], n.DotsNet [Сети],       
			 	pd.Pay1Km*m.Dist [Оплата пробега],
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0) [Оплата точки],
        pd.Pay1Kg*(m.[Weight]+m.dopWeight) [Оплата тоннаж],
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0) [Оплата часы],
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0)) [Оплата сети],
        pd.Pay1DotOver*(case when m.Dots>=25 then m.Dots-25 else 0 end) [Оплата точки сверх],
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end) [Оплат все точки(<25)],
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end) [Оплат все точки(>25)],
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0) [Оплата разряд0],
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0) [Оплата разряд1],
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0) [Оплата разряд2],
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0) [Оплата разряд3],
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) [Оплата прицеп],
        pd.Pay1Kg [1кг],
        pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) ) [Оплата бонуса],
        a.[expense] [Расходы СТ],          
        a.[gsm] [ГСМ],
        a.delivpay,
        iif(a.expense>0, a.delivpay-a.expense-a.gsm,0) [Зарплата],
        /*
        cast(pd.Pay1Km*m.Dist+
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
        pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
        pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
        pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0))   as money)-m.Peni+iif(a.[expense]=0,0,a.[expense]+a.[gsm]+/*a.[rash]*/ iif(a.expense>0, a.delivpay-a.expense-a.gsm,0))
        */
        a.delivpay [Итого сумма],
        /*
        cast(
        iif(isnull(m.[Weight]+m.dopWeight,0)=0,0,
        (cast(pd.Pay1Km*m.Dist+
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
        pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
        pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
        pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0))   as money)-m.Peni+iif(a.[expense]=0,0,a.[expense]+a.[gsm]+/*a.[rash]*/ iif(a.expense>0, a.delivpay-a.expense-a.gsm,0))) / (m.[Weight]+m.dopWeight))
        as decimal(15,2)) 
        */
        a.delivpay / (m.[Weight]+m.dopWeight)[Итого 1кг]
from #msh 
left join #add_marsh a on a.mhid=#msh.mhid and a.[old]=0
join dbo.marsh m on m.mhid=#msh.mhid 
join dbo.vehicle v on v.v_id=m.v_id
left join 
  (select c.mhid, count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) as DotsNet
   from nc c join defcontract f on c.dck=f.dck
         join def d on c.b_id=d.pin
         join dbo.agentlist a on f.ag_id=a.ag_id
   where a.depid in (3,26)
   group by c.mhid) n on n.mhid=m.mhid
join dbo.Drivers r on m.drId=r.drId
cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.drID=m.drId) ms
join NearLogistic.nltariffparams pd on #msh.drv=pd.nltariffparamsid
join NearLogistic.nltariffsdet d on pd.nltariffparamsid=d.nltariffparamsid
join nearlogistic.nltariffs t on t.nltariffsid=d.nltariffsid

union 

select 	m.nd, m.marsh,t.tariffname,iif(isnull(m.km1 - m.km0,0)<=0,m.calcdist,m.km1 - m.km0) [CalcDist],m.[Weight],m.Dots, n.DotsNet,        
			 	pd.Pay1Km*m.Dist as Pay1Km,
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0) as Pay1Dot,
        pd.Pay1Kg*(m.[Weight]+m.dopWeight) as Pay1Kg,
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0) as Pay1Hour,
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0)) as Pay1DotNet,
        pd.Pay1DotOver*(case when m.Dots>=25 then m.Dots-25 else 0 end) as Pay1DotOver,
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end) as PayAllDot,
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end) as PayAllDotOver,
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0) as Rate0Rank,
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0) as Rate1Rank,
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0) as Rate2Rank,
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0) as Rate3Rank,
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end) as Trailer,
        pd.Pay1Kg [1кг],
        pd.Bonus*( iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0) ) as Bonus,
        a.[expense] [Расходы СТ],          
        a.[gsm] [ГСМ],
        a.delivpay,
        /*a.[rash]*/ iif(a.expense>0, a.delivpay-a.expense-a.gsm,0) [Зарплата],
        /*
        cast(pd.Pay1Km*m.Dist+
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
        pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
        pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
        pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0)        
        )   as money)-m.Peni+iif(a.[expense]=0,0,a.[expense]+a.[gsm]+/*a.[rash]*/ iif(a.expense>0, a.delivpay-a.expense-a.gsm,0)) as sm
        */
        a.delivpay,
        /*
        cast(
        iif(isnull(m.[Weight]+m.dopWeight,0)=0,0,
        (cast(pd.Pay1Km*m.Dist+
        pd.Pay1Dot*iif(m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0)>0, m.Dots-isnull(n.dotsnet,0)-iif(m.Dots-25>0,m.Dots-25,0), 0)+
        pd.Pay1Kg*(m.[Weight]+m.dopWeight)+
        pd.Pay1Hour*isnull(iif(DATEDIFF(hour,m.TimeGo,m.TimeBack)<=0,0,DATEDIFF(hour,m.TimeGo,m.TimeBack)),0)+
        pd.Pay1DotNet*iif(isnull(n.dotsnet,0)>=25,25,isnull(n.dotsnet,0))+
        pd.Pay1DotOver*(case when m.Dots>25 then m.Dots-25 else 0 end)+
        pd.PayAllDot*(case when m.Dots<25 then 1 else 0 end)+
        pd.PayAllDotOver*(case when m.Dots>=25 then 1 else 0 end)+
        pd.Rate0Rank*iif(r.nlPersonalRank=0 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate1Rank*iif(r.nlPersonalRank=1 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate2Rank*iif(r.nlPersonalRank=2 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Rate3Rank*iif(r.nlPersonalRank=3 and ms.DrvMhID=m.mhID,1, 0)+
        pd.Trailer*(case when isnull(m.V_idTR,0)>0 then 1 else 0 end)+
        pd.Bonus*(iif((n.DotsNet*@Dot2NetDot+(m.Dots-n.DotsNet) > @DotsBasePlan),1,0)
        )   as money)-m.Peni+iif(a.[expense]=0,0,a.[expense]+a.[gsm]+/*a.[rash]*/ iif(a.expense>0, a.delivpay-a.expense-a.gsm,0))) / (m.[Weight]+m.dopWeight))
        as decimal(15,2)) 
        */
        a.delivpay / (m.[Weight]+m.dopWeight)
from #msh
left join #add_marsh a on a.mhid=#msh.mhid and a.[old]=1
join dbo.marsh m on m.mhid=#msh.mhid 
left join 
  (select c.mhid, count(distinct (case when isnull(d.vmaster,0)>0 then d.vmaster else d.pin end)) as DotsNet
   from nc c join defcontract f on c.dck=f.dck
         join def d on c.b_id=d.pin
         join dbo.agentlist a on f.ag_id=a.ag_id
   where a.depid in (3,26)
   group by c.mhid) n on n.mhid=m.mhid
join dbo.Drivers r on m.drId=r.drId
join dbo.vehicle v on m.v_id=v.v_id
cross apply (select min(s.mhid) as DrvMhId from marsh s where s.nd=m.nd and s.drID=m.drId) ms
join NearLogistic.nltariffparams pd on #msh.drv_new=pd.nltariffparamsid 
join NearLogistic.nltariffsdet d on pd.nltariffparamsid=d.nltariffparamsid
join nearlogistic.nltariffs t on t.nltariffsid=d.nltariffsid

order by 1,2

--select * from #msh
--select * from #add_marsh

if object_id('tempdb..#msh') is not null drop table #msh
end