create procedure dbo.EloadVehicleNotUse
@nd datetime
as 
begin
if object_id('tempdb..#tmpveh') is not null drop table #tmpveh

create table #tmpveh(v_id int, vName varchar(100), crid int)
insert into #tmpveh
select v.v_id,
			 v.model+' '+v.RegNom,
       v.CrId       
from dbo.Vehicle v 
where v.Closed=0
			and not v.v_id in (select m.v_id from dbo.marsh m where nd=@nd)
      and v.trailer=0

select t.vName [Транспорт],
			 isnull(isnull(d.fio,'<..>')+', '+isnull(d.phone,'<..>'),'<..>') [Водитель],
			 cast(iif(t.crid=7,1,0) as bit) [Наш],
       isnull(c.crName,'<..>')+' '+iif(isnull(c.crid,7)<>7,c.Phone,'') [Грузоперевозчик],
       isnull((
       case when x.tmwork='00:00' then 'V'
            when x.tmwork is null then 'X'
            when x.reserve=1 then 'R'
            else rtrim(ltrim(x.tmWork)) end),'<..>') [Календарь]
from #tmpveh t
left join dbo.carriers c on c.crid=t.crid
left join (select a.* from dbo.vehrasp a where a.nd=@nd) x on x.v_id=t.v_id
left join dbo.drivers d on d.v_id=t.v_id
order by 3 desc, 1

drop table #tmpveh
end