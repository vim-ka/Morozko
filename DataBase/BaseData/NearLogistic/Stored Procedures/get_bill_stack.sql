CREATE procedure NearLogistic.get_bill_stack 
@bill_stack_id int output, @force bit, @op int, 
@remark varchar(500), @mhids varchar(5000) ='',
@nd1 datetime, @nd2 datetime 
as 
begin
set nocount on
declare @mhid int

if @force=1
begin
	insert into nearlogistic.bill_stack(op,bill_name) values(@op,@remark)
  select @bill_stack_id=@@identity
  
  if object_id('tempdb..#mhids') is not null drop table #mhids
  create table #mhids(mhid int)
  
  if @mhids='' insert into #mhids select b.mhid from nearlogistic.billsSum b --nearlogistic.bills b 
    join dbo.marsh m on m.mhid=b.mhid 
  						 where bill_stack_id=0 and m.mstatus in (3,4) and m.nd between @nd1 and @nd2 and lockbill=0 group by b.mhid
  else insert into #mhids select value from string_split(@mhids, '#') group by value
  
	update b set bill_stack_id=@bill_stack_id 
  --from nearlogistic.bills b
  from nearlogistic.billsSum b
  join #mhids on #mhids.mhid=b.mhid
  where bill_stack_id=0
  
  if object_id('tempdb..#mhids') is not null drop table #mhids
end

select m.nd, m.marsh, m.direction, d.fio, v.model+', '+v.regnom [veh],
       isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [client], sum(b.mas) [mas], sum(b.vol) [vol], sum(b.distance) [distance],
       sum(b.req_pay) req_pay, m.mhid, b.bill_stack_id, b.casher_id, m.lockbill, b.is_old, m.lock_remark,b.nal
--from nearlogistic.bills b
from nearlogistic.billsSum b
join dbo.marsh m on m.mhid=b.mhid
join dbo.drivers d on d.drid=m.drid
join dbo.vehicle v on v.v_id=m.v_id
left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
left join dbo.def f on f.pin=dc.pin
left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
where b.bill_stack_id=@bill_stack_id and m.mstatus in (3,4)
group by m.nd, m.marsh, m.direction, d.fio, v.model+', '+v.regnom, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))), 
				 m.mhid, b.bill_stack_id, b.casher_id, m.lockbill, b.is_old, m.lock_remark,b.nal

set nocount off
end