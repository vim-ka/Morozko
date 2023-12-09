CREATE procedure NearLogistic.lock_marsh @mhid int, @remark varchar(500) =''
as
begin
 update m set m.lockbill=cast(iif(m.lockbill=0,1,0) as bit), m.lock_remark=iif(m.LockBill=0,@remark,null)
  from nearlogistic.bills b
  join dbo.marsh m on m.mhid=b.mhid 
  where b.bill_stack_id=0 and m.mhid=@mhid
end