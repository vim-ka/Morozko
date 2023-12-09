CREATE procedure dbo.EloadNLReport
@nd1 datetime,
@nd2 datetime
as
begin
select convert(varchar,[nd],104) [Дата],
			 sum(iif([mhid]=0,sp,0)) [Нулевой],
       sum(iif([delivcancel]=1,sp,0)) [Отмена] 
from dbo.nc 
where [sp]>0 
			and ([mhID]=0 or ([delivcancel]=1 and mhid>0))
      and [nd] between @nd1 and @nd2 
group by [nd]
order by [nd]

select convert(varchar,[nd],104) [Дата],
			 [DName] [Отдел],
			 sum(iif([mhid]=0,sp,0)) [Нулевой],
       sum(iif([delivcancel]=1,sp,0)) [Отмена] 
from dbo.nc 
join dbo.agentlist l on l.ag_id=nc.ag_id
join dbo.deps d on d.depid=l.depid
where [sp]>0 
			and ([mhID]=0 or ([delivcancel]=1 and mhid>0))
      and [nd] between @nd1 and @nd2 
group by [nd],[DName]
order by [nd],[DName]

select m.marsh [Маршрут],
			 convert(varchar,m.nd,104) [Дата],
			 isnull(
       stuff((select N''+d.dname+';'
			 from dbo.nc c
       join dbo.agentlist l on l.ag_id=c.ag_id
       join dbo.deps d on d.depid=l.depid
       where c.mhid=m.mhid
       group by d.dname
       for xml path(''), type).value('.','varchar(max)'),1,0,''),
       '<..>') [Отделы],
       m.earnings [Рентабельность]       
from dbo.marsh m 
where m.mstatus between 2 and 4
		  and m.[nd] between @nd1 and @nd2 
      and m.selfship=0
      and m.earnings<=0
      and not m.marsh in (0,99)
      and m.delivcancel=0
order by m.nd, m.marsh
end