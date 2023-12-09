CREATE procedure NearLogistic.get_bill_stacks
as
begin
	select x.*, isnull(a.[sm],0) [sum], cast(isnull(a.nal,0) as bit) [nal]
  from (
	select s.bill_stack_id, s.bill_name, s.op, u.fio, s.comp, s.date_create
  from nearlogistic.bill_stack s join dbo.usrpwd u on u.uin=s.op
  union all select 0, 'Рассчитанные счета', null, null, null, null) x
  left join (select b.bill_stack_id [id], sum(b.req_pay) [sm], max(cast(b.nal as int)) [nal] from NearLogistic.billsSum b  --from NearLogistic.bills b 
  					 join dbo.marsh m on m.mhid=b.mhid where m.mstatus in (3,4)
             group by b.bill_stack_id) a on a.[id]=x.bill_stack_id
  
  order by 1
end