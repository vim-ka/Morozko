CREATE PROCEDURE ELoadMenager.Eload_CargoNakl
@nd1 datetime,
@nd2 datetime
AS
BEGIN
set nocount on
select  datename(month,p.nd) [Месяц],
       iif(v.CrId=7,cast(1 as bit),cast(0 as bit)) [Морозко],
       count(distinct p.datnom) [Кол-во] 
from dbo.PrintLog p 
inner join dbo.nc c on p.DatNom=c.datnom
inner join dbo.marsh m on m.marsh=c.marsh and m.nd=c.nd
inner join dbo.vehicle v on v.v_id=m.v_id
where p.tip & 4 <> 0 
      and p.nd between @nd1 and dateadd(day,1,@nd2)
      and c.frizer=0
      and c.tara=0
      and c.actn=0
      and not c.marsh in (0,99)
group by datename(month,p.nd),iif(v.CrId=7,cast(1 as bit),cast(0 as bit))
order by 1,2 desc

if object_id('tempdb..#tmp') is not null drop table #tmp
create table #tmp (ord int, dt varchar(25), ourname varchar(200), crid varchar(200), n int, nd varchar(15),datnom int) 
insert into #tmp
select year(p.nd)*100+month(p.nd) [ord],
			 datename(month,p.nd)+' '+cast(year(p.nd) as varchar) [dt],
       fc.ourname,
       ca.crName [crID],
       c.datnom % 10000 [n],
       convert(varchar,c.nd,104) [nd],
       c.datnom
from dbo.PrintLog p 
inner join dbo.nc c on p.DatNom=c.datnom
inner join dbo.marsh m on m.marsh=c.marsh and m.nd=c.nd
inner join dbo.vehicle v on v.v_id=m.v_id
inner join dbo.carriers ca on ca.crid=v.crid 
inner join dbo.firmsconfig fc on fc.our_id=c.ourid
where p.tip & 4 <> 0 and c.frizer=0 and c.tara=0
      and p.nd between @nd1 and dateadd(day,1,@nd2)
      and c.actn=0 and not c.marsh in (0,99)
order by year(p.nd)*100+month(p.nd),2 desc,3

select a.dt [Дата], a.ourname [Фирма], a.crid [Грузоперевозчик],
		   stuff((select N' '+cast(x.n as varchar)+' от '+x.nd+';'
              from #tmp x             
              where x.dt=a.dt and x.ourname=a.ourname and x.crid=a.crid
              order by x.datnom
              for xml path(''), type).value('.','varchar(max)'),1,1,'' ) [Накладные]
from #tmp a
group by a.dt, a.ourname, a.crid, a.ord
order by a.ord,3,2
  
if object_id('tempdb..#tmp') is not null drop table #tmp
set nocount off
END