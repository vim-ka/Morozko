CREATE PROCEDURE ELoadMenager.Eload_NLComparemarshs
@nd1 datetime,
@nd2 datetime
as
begin
select cast(iif(v.crid=7,1,0) as bit) [Наш],
			 convert(varchar,m.[nd],104) [Дата],
			 m.marsh [Маршрут],
       (select rs.regname from nearlogistic.getregsstring(m.nd) rs where rs.mhid=m.mhid) [Направление],
       isnull(d.fio,'<..>')+', '+isnull(d.phone,'<..>') [Водитель],
       isnull(v.model,'<..>')+', '+isnull(v.regnom,'<..>') [Транспорт],
       m.calcdist [Рассчет],
       m.dist [Факт],
       m.dist-m.calcdist [Разница],
       cast(iif(m.calcdist=0,0,(m.dist-m.calcdist)/m.calcdist * 100.00) as decimal(15,2)) [%]
from marsh m
left join dbo.drivers d on d.drid=m.drid
left join dbo.vehicle v on v.v_id=m.v_id
where m.[nd] between @nd1 and @nd2
			and (m.VedNo>0 or m.listno>0 or m.mstatus in (2,3,4))
      and m.selfship=0
      and not m.marsh in (0,99)
order by m.nd, m.marsh      
end