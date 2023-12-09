CREATE procedure NearLogistic.bill_exclude
@bill_id int
as
begin
 update b set b.bill_stack_id=case when b.bill_stack_id = -1 then 0
                   when b.bill_stack_id = 0 then -1
                        else b.bill_stack_id end
  from nearlogistic.bills b
  where b.bill_id = @bill_id
end