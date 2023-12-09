CREATE PROCEDURE dbo.EloadGetStack
@dt1 datetime,
@dt2 datetime,
@id int
AS
BEGIN
set nocount on
declare @dt datetime
declare @sql varchar(max)
declare @ColumnsValues varchar(1000)

set @ColumnsValues=''

set @sql=''
if object_id('tempdb..#Pers') is not null drop table [#Pers]	
if object_id('tempdb..#Dates') is not null drop table [#Dates]	
if object_id('tempdb..#Stack') is not null drop table [#Stack]	
create table [#Pers] (PersID int)
insert into [#Pers] 
select c.PersID 
from [HRMain].[dbo].WorkgroupContains c 
inner join [HRMain].[dbo].pers p on c.PersID=p.PersID
where p.PersState not in (-1,5) 
			and c.WorkgroupID=@ID      
create nonclustered index idx_tmppers1 on #pers(persid)
create table [#Dates] (dt datetime)
set @dt=@dt1
while @dt<=@dt2
begin
	insert into [#Dates] VALUES(@dt)
  
  if @ColumnsValues=''
  	set @ColumnsValues='['+convert(varchar,@dt,104)+']'
  else
  	set @ColumnsValues=@ColumnsValues+',['+convert(varchar,@dt,104)+']'
	
 set @dt=DATEADD(day,1,@dt)
end
create nonclustered index idx_tmpdates on #dates(dt)
create table [#Stack] (StackID int identity not null,
											 PersID int not NULL,
											 PersFIO varchar(100) not null,
											 WorkDate datetime not null,
											 WorkDateValue varchar(100),
                       FHours int										 
											 )
insert into [#Stack] (PersID,PersFIO,WorkDate,FHours)
select 	s.PersID, 
				isnull(s.SecondName,'*')+' '+isnull(s.FirstName,'*')+' '+isnull(s.MiddleName,'*'),
				d.dt,
        (SELECT FHOURS FROM HRMAIN.DBO.WORKSHEET W WHERE W.PERSID=S.PERSID AND W.WORKDATE=D.DT)
from [#Pers] p
inner join [HRMain].[dbo].Pers s on p.persid=s.PersID
inner join [#Dates] d on 1=1
order by 2,3
create nonclustered index idx_tmpstack1 on #stack(persid)
create nonclustered index idx_tmpstack2 on #stack(workdate)
create nonclustered index idx_tmpstack3 on #stack(persid,workdate)

update [#Stack] set WorkDateValue=[HRMain].[dbo].GetDayGrafficName(PersID,WorkDate)
										
set @sql=N'select cast((row_number() over(order by PersFIO)) as varchar)+''. ''+PersFIO [Сотрудник],'
set @sql=@sql+@ColumnsValues+N',sm.[hours] / 60.0 [ИтогоЧасов] '
set @sql=@sql+N' from (select distinct PersID, PersFIO from [#Stack]) x '
set @sql=@sql+N'inner join (select PersID, '+@ColumnsValues+' from '
set @sql=@sql+N'(select persid, convert(varchar,workdate,104) as [ColumnName], WorkDateValue from [#Stack]) as [src] '
set @sql=@sql+N'pivot(max(WorkDateValue) for [ColumnName] in ('+@ColumnsValues+')) as [pvt]) as [DateValue] on [DateValue].PersID=x.PersID '
set @sql=@sql+N'inner join (select sum([#Stack].FHours) [hours],[#Stack].PersID from [#Stack] group by [#Stack].PersID) sm on sm.PersID=x.PersID '
exec(@sql)

drop table [#Stack]
drop table [#Pers]
drop table [#Dates]
set nocount off
END