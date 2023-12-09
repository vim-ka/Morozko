create procedure nearlogistic.transit_marsh_operations
@mhid int, @mhids nvarchar(500), @operation_type int, --0 - добавление, 1 - удаление
@op int, @plid int =7
as
begin
set nocount on

if @mhid=-1 and @operation_type=0 --создание нового транзитного рейса
begin
 declare @nd datetime =dbo.today(), @marsh int
  if object_id('tempdbb..#tmp_new_marhs') is not null drop table #tmp_new_marhs
  create table #tmp_new_marhs (id int) 
  insert into #tmp_new_marhs
  select r.num from nearLogistic.get_range(500,699) r
  where not exists(select 1 from dbo.marsh m where m.marsh=r.num and m.nd=@nd) and r.num<>99
  if not exists(select top 1 id from #tmp_new_marhs) 
    set @marsh=1
  else    
    select @marsh=min(id) from #tmp_new_marhs where id>0
  if object_id('tempdbb..#tmp_new_marhs') is not null drop table #tmp_new_marhs
  insert into [dbo].marsh(nd,marsh,plid) values(@nd,@marsh,@plid)
  set @mhid=scope_identity()
    
  insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType) 
  values(@op,@mhid,0,'','',4)
end

update m set m.parent_mhid=iif(@operation_type=1,0,@mhid)
from dbo.marsh m
join string_split(@mhids,'#') s on s.value=m.mhid

set nocount off
end