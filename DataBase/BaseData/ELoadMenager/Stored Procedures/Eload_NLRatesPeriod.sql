CREATE PROCEDURE ELoadMenager.Eload_NLRatesPeriod
@nd1 datetime,
@nd2 datetime
AS
BEGIN
select convert(varchar,@nd1,104)+'-'+convert(varchar,@nd2,104) as [Период],
       sum(m.Dots) as [Количество сработавших тт],
       count(m.marsh) as [Количество вывезенных маршрутов],
       round(avg(m.weight+m.dopweight),2) as [Средняя загрузка транспорта, кг],
       round(sum(m.weight+m.dopweight),2) as [Всего вывезено, кг],
       round(sum(d.OplataSum),2) as [Затраты на доставку, руб],
       round(sum(d.OplataSum)/sum(m.weight+m.dopweight),2) as [Затраты на доставку 1кг груза, руб],
       sum(d.OplataSum)/ (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Затраты на доставку 1руб. продукции],
       round(sum(d.OplataSum)/sum(m.Dots),2) as [Средние затраты на доставку в 1 точку],
       (select sum(sp) from nc where ND>=@nd1 and ND<@nd2 and tara=0 and frizer=0  and stip<>4 and Marsh<>99 and marsh<200 and (marsh>0 or sp<0)/*and sp>0*/) as [Объём продаж]            
from Marsh m join NearLogistic.nlListPayDet d on m.Marsh=d.Marsh and m.ND=d.Nd
where m.ND>=@nd1 and m.ND<@nd2 and m.mState=2 and m.Marsh<>99 and m.SelfShip<>1  and m.weight>0

--/*
select x.[Водитель],
			 count(*) [Маршрутов],
			 sum(x.[netDots]) [Сетевые],
       sum(x.[Dots]) [Розничные],
       sum(x.[netWeight]) [Сетевой тоннаж],
       sum(x.[Weight]) [Розничный тоннаж]
from (
--*/
select m.nd [Дата],
			 m.marsh [Маршрут],
			 d.fio [Водитель],			 
			 count(distinct iif(a.depid=3,c.b_id,0))-1 [netDots],
       count(distinct iif(a.depid<>3,c.b_id,0))-1 [Dots],
       sum(cast(iif(a.depid=3,mr.Weight_,0) as decimal(15,2))) [netWeight],
       sum(cast(iif(a.depid<>3,mr.Weight_,0.0) as decimal(15,2))) [Weight]
from dbo.marsh m 
join nearlogistic.marshrequests mr on mr.mhid=m.mhid and mr.reqtype=0
join dbo.drivers d on d.drid=m.drid
join dbo.nc c on c.datnom=mr.reqid 
join dbo.defcontract dc on dc.dck=c.dck
join dbo.agentlist a on a.ag_id=dc.ag_id
join dbo.vehicle v on v.v_id=m.v_id
where m.nd between @nd1 and @nd2
			--and (m.ListNo<>0 or m.VedNo<>0)
      and m.marsh<200
      and not m.marsh in (0,99)
      and m.selfship=0
      and v.crid=7
group by m.nd, m.marsh, d.fio
--/*
) x
group by x.[Водитель]      
--*/
END