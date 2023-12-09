create procedure nearlogistic.del_bill_stack
@bill_stack_id int, @op int
as
begin
 update b set b.bill_stack_id=0
  from nearlogistic.bills b
  where b.bill_stack_id=@bill_stack_id
  
  delete from nearlogistic.bill_stack where bill_stack_id=@bill_stack_id
end