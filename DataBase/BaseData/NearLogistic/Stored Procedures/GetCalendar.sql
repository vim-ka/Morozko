
CREATE PROCEDURE NearLogistic.GetCalendar
@dt datetime
AS
BEGIN
set nocount on
declare @dt1 datetime 
declare @dt2 datetime 
declare @dtString varchar(2000)
declare @sql varchar(max)

set @dt2=eomonth(@dt)
set @dt1=dateadd(month,-1,dateadd(day,1,@dt2))

if object_id('tempdb..#dates') is not null drop table #dates
create table #dates (dt datetime)

while @dt1<=@dt2
begin
 insert into #dates values(@dt1)
  set @dt1=dateadd(day,1,@dt1)
end

create nonclustered index idx_dates on #dates(dt)

create table #VehCalendar (v_id int,
              tip int, 
              vName varchar(100),
                           vTip int,
                           vTipName varchar(50),
                           drID int,
                           drName varchar(150),
                           drPhone varchar(50),
                           dt datetime,
                           CellValue varchar(15),
                           logtype int,
                           reg_id char(5),
                           isHeader bit,
                           isMorozko bit)
if object_id('tempdb..#marshDist') is not null drop table #marshDist

create table #marshDist (dt datetime, drID int, dist int)

insert into #marshDist
select m.nd, m.drID, sum(iif(m.dist=0,isnull(m.calcdist,0),m.dist))
from dbo.marsh m
inner join #dates on m.nd=#dates.dt
where isnull(m.drID,0)<>0
group by m.nd, m.drID

create nonclustered index marshDist_idx on #marshDist(dt)
create nonclustered index marshDist_idx1 on #marshDist(drID)
                           
insert into #VehCalendar(drID,drName,drPhone,v_id,vName,vTip,vTipName,dt,tip,logtype,reg_id,isHeader,isMorozko)
select  d.drId,
    d.Fio,
        d.Phone,
        d.v_id,
        v.Model+' '+v.RegNom,
        v.VTip,
        t.nlVehicleTypeName,
        #dates.dt,
        case when c.PhysPerson = 0 and c.NDS=0 then 1 
             when c.PhysPerson = 0 and c.NDS=1 then 2
             when c.PhysPerson =  1 then 3
             else 0 end,
        d.LgstType,
        v.Reg_ID,
        cast(0 as bit),
        iif(c.crID=7,cast(1 as bit),cast(0 as bit))
from [dbo].drivers d 
left join [dbo].vehicle v on v.v_id=isnull(d.v_id,0)
left join [nearlogistic].nlVehicleType t on t.nlVehicleTypeID=v.vtip
left join dbo.Carriers c on c.crID=v.crID
inner join #dates on 1=1
where d.closed=0
   and d.trId in (6,7)   

insert into #VehCalendar(drName,logtype,isHeader,tip)
select 'Прямая логистика',cast(1 as int),cast(1 as bit),-2
union 
select 'Обратная логистика',cast(0 as int),cast(1 as bit),-2

insert into #VehCalendar(drName,Reg_id,logtype,isHeader,tip)
select r.Place,r.Reg_ID,l.lgsType,cast(1 as bit),-1 
from (select a.reg_id,a.place from dbo.regions a union select '','Регион не задан') r 
inner join (select 0 [lgsType] union select 1) l on 1=1 
where r.Reg_ID in (select distinct reg_id from #VehCalendar)

delete v
from #VehCalendar v 
inner join (select logtype,reg_id
            from #VehCalendar
            where tip<>-2
            group by logtype,reg_id
            having count(*)=1) x on v.logtype=x.logtype and v.reg_id=x.reg_id

create nonclustered index idx_VehCalendarV_ID on #VehCalendar(v_id)
create nonclustered index idx_VehCalendardrid on #VehCalendar(drid)
create nonclustered index idx_VehCalendarDT on #VehCalendar(DT)
create nonclustered index idx_VehCalendarDTV_ID on #VehCalendar(dt,v_id)

update v set v.CellValue=case when abs(datediff(day,v.dt,getdate()))>1 and isnull(d.dist,0)<>0  then cast(d.dist as varchar) else
             case when r.tmwork='00:00' then 'V'
               when r.tmwork is null then 'X'
                              when r.reserve=1 then 'R'
                              else rtrim(ltrim(tmWork)) end end
from #VehCalendar v
inner join dbo.vehrasp r on r.planday=v.dt and r.v_id=v.v_id
left join #marshDist d on d.drID=v.drID and d.dt=v.dt

update #VehCalendar set #VehCalendar.CellValue='X'
where #VehCalendar.CellValue is null

set @dtString=stuff((
       select N',['+convert(varchar,dt,104)+']'
       from #dates 
       for xml path(''), type).value('.','varchar(max)'),1,1,'')

set @sql='select pvt.drID,drName,drPhone,v_id,tip,vName,vTip,vTipName,logtype,reg_id,isHeader,isnull(isMorozko,0) isMorozko,isnull(md.sd,0) dist,'
     +@dtString
     +' from #VehCalendar pivot(min(CellValue) for dt in ('+@dtString+')) as pvt'
         +' left join (select drID,sum(dist) sd from #marshDist group by drID) md on md.drID=pvt.drID'
         +' order by logtype,reg_id,isHeader desc,tip,drName'
exec(@sql)

drop table #VehCalendar
drop table #dates
drop table #marshDist
set nocount off
END