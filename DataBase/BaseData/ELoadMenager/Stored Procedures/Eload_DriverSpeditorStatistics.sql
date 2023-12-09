﻿CREATE PROCEDURE ELoadMenager.Eload_DriverSpeditorStatistics
@nd1 datetime,
@nd2 datetime
AS
BEGIN
declare @sumDriver decimal(15,2)
declare @sumSpeditor decimal(15,2)
declare @dotDriver decimal(15,2)
declare @dotSpeditor decimal(15,2)

if object_id('temp_db..#baseDrv') is not null drop table #baseDrv
if object_id('temp_db..#baseSped') is not null drop table #baseSped

select d.fio [Водитель],
       sum(iif(isnull(m.SpedDrID,0)<>0,m.Dots /*/ 2*/,m.Dots)) [Точек],
       cast(sum(iif(isnull(m.SpedDrID,0)<>0,m.Weight /*/ 2.0*/, m.Weight)) as decimal(15,2)) [Тоннаж, кг],
       cast(0 as decimal(15,2)) [Процент],
       sum(iif(isnull(m.Dist,0)<>0,m.Dist ,m.CalcDist)) as [Пробег, км]
      -- sum(mreq.CountReq) as CountReq
into #baseDrv
from dbo.marsh m
join dbo.drivers d on d.drId=m.drId
join person p on p.p_id=d.p_id
left join (select mr.mhid,count(distinct mr.pinto) as CountReq from NearLogistic.MarshRequests mr where mr.ReqType<>-1 group by mr.mhid) mreq on mreq.mhid=m.mhid
inner join dbo.Vehicle v on v.v_id=m.v_id
where m.nd between @nd1 and @nd2
      --and Away=1
      and MStatus in (2,3,4)
      and DelivCancel=0
      and v.CrId=698
      and p.depid<>45
group by d.fio

      
select d.fio [Экспедитор],
			 sum(iif(isnull(m.drId,0)<>0 and v.crid=7,m.Dots / 2,m.Dots)) [Точек], 
       cast(sum(iif(isnull(m.drId,0)<>0 and v.crid=7,m.weight / 2.0,m.weight)) as decimal(15,2)) [Тоннаж, кг], 
       cast(0 as decimal(15,2)) [Процент]
into #baseSped
from marsh m 
join drivers d on m.Speddrid=d.drid 
join person p on p.p_id=d.p_id
join vehicle v on m.v_id=v.v_id
where m.nd between @nd1 and @nd2
		  --and Away=1
      and MStatus in (2,3,4)
      and DelivCancel=0
      --and p.depid<>45
      --and d.trID<>6
group by d.fio

select @sumDriver=sum([Тоннаж, кг]) from #baseDrv where [Водитель] is not null
select @sumSpeditor=sum([Тоннаж, кг]) from #baseSped where [Экспедитор] is not null

select @dotDriver=sum([Точек]) from #baseDrv where [Водитель] is not null
select @dotSpeditor=sum([Точек]) from #baseSped where [Экспедитор] is not null

update #baseDrv set [Процент]  = cast((((([Тоннаж, кг]/@sumDriver) + ([Точек]/@dotDriver))*100.0) / 2.0) as decimal(15,2))
update #baseSped set [Процент] = cast((((([Тоннаж, кг]/@sumSpeditor) + ([Точек]/@dotSpeditor))*100.0) / 2.0) as decimal(15,2))

select row_number() over(order by [Точек] desc) [№],
			 *,
       cast([Тоннаж, кг]/@sumDriver as decimal(15,4))*100.0 [Вклад, тоннаж],
       cast([Точек]/@dotDriver*1.0 as decimal(15,4))*100.0 [Вклад, точек],
       cast([Тоннаж, кг]/@sumDriver+[Точек]/@dotDriver*1.0 as decimal(15,4))*100.0 [Сумма вкладов]
from #baseDrv
select row_number() over(order by [Точек] desc) [№],
			 *,
       cast([Тоннаж, кг]/@sumSpeditor as decimal(15,4))*100.0 [Вклад, тоннаж],
       cast([Точек]/@dotSpeditor*1.0 as decimal(15,4))*100.0 [Вклад, точек], 
       cast([Тоннаж, кг]/@sumSpeditor+[Точек]/@dotSpeditor*1.0 as decimal(15,4))*100.0 [Сумма вкладов]       
from #baseSped

drop table #baseDrv
drop table #baseSped
END