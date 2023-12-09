CREATE procedure NearLogistic.recalculate_liter_id
@mhid int
as
begin
set nocount on
declare @tran nvarchar(50) ='', @max_liter_id int ='';
set @tran=N'recalculate_liter_id';
begin tran @tran
if object_id('tempdb..#reqs') is not null drop table #reqs;create table #reqs (id int,pin int, liter_id int);
create nonclustered index reqs_idx on #reqs(id);create nonclustered index reqs_idx1 on #reqs(pin);
insert into #reqs
select reqid, pinto [pin], liter_id 
from nearlogistic.marshrequests mr 
where mr.mhid=@mhid
select @max_liter_id=max_liter_id from dbo.marsh where mhid=@mhid
;
update a set a.liter_id=b.liter_id
from #reqs a
join (select pin, liter_id from #reqs where liter_id>0) b on b.pin=a.pin
where a.liter_id=0
;
update a set a.liter_id=b.liter_id
from #reqs a
join (select pin, row_number() over(order by pin) + @max_liter_id [liter_id]
   from (select pin, liter_id from #reqs where liter_id=0 group by pin, liter_id) x) b on a.pin=b.pin
where a.liter_id=0      
;
update mr set mr.liter_id=#reqs.liter_id
from nearlogistic.marshrequests mr 
join #reqs on #reqs.id=mr.reqid
update dbo.marsh set max_liter_id=(select max(liter_id) from #reqs) where mhid=@mhid
;
if object_id('tempdb..#reqs') is not null drop table #reqs;
if @@trancount>0 commit tran @tran else rollback tran @tran;
set nocount off
end