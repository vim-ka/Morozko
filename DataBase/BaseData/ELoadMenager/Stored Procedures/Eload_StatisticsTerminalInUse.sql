CREATE PROCEDURE ELoadMenager.Eload_StatisticsTerminalInUse
@nd1 datetime,
@nd2 datetime
AS
begin
set nocount on
declare @comp_str varchar(500)
declare @temp varchar(500)
declare @max_term int
declare @max_mterm int

if object_id('tempdb..#terminals') is not null drop table #terminals
create table #terminals ([ishand] bit,[comp] varchar(50), [cnt] int, [percentage] decimal(5,2))

declare cur cursor for
select distinct comp 
from nvzakaz 
where done=1 
			and nd between convert(varchar,dateadd(year,-1,getdate()),104) and convert(varchar,getdate(),104)
      and charindex('#',comp)>0
      and patindex('%term%',comp)>0
      
open cur
fetch next from cur into @comp_str

while @@fetch_status=0
begin
	insert into #terminals (comp)
  select distinct replace(value,'@cancel','')
  from string_split(@comp_str,'#')
  where not exists(select * from #terminals where comp=replace(value,'@cancel',''))
  			and value like '%term%'
  fetch next from cur into @comp_str
end

close cur
deallocate cur

update t set [ishand] = cast(iif(comp like 'terminal%',0,1) as bit),
						 [cnt]    = (select count(distinct z.nzid) from dbo.nvzakaz z where z.nd between @nd1 and @nd2 and comp like '%'+t.comp+'%') 
from #terminals t

select @max_term=sum(cnt) from #terminals where ishand=0
select @max_mterm=sum(cnt) from #terminals where ishand=1

update t set percentage=cast(case when @max_mterm=0 and ishand=1 then 0
													 				when @max_term=0 and ishand=0 then 0
                                  when ishand=0 then cnt*1.0 / @max_term
                                  when ishand=1 then cnt*1.0 / @max_mterm end
													   as decimal(5,2)) * 100
from #terminals t

select comp [Терминал],
			 cnt [КоличествоСтрок],
       percentage [ПроцентИспользования]
from #terminals
order by ishand, percentage desc, cnt desc, comp

if object_id('tempdb..#terminals') is not null drop table #terminals
set nocount off
end