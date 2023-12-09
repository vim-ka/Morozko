CREATE procedure NearLogistic.print_bills_cashers @bill_stack_id int, @casher_id int, @is_old bit, @nal int =0
as
begin
	set nocount ON 
	select b.casher_id, 'C'+cast(b.bill_stack_id as varchar)+'/'+cast(b.casher_id as varchar) [bill_nom], 
  		   isnull(c.casher_name, isnull(fc.ourname,isnull(f.gpname, f.brname))) [bill_casher], sum(b.req_pay/iif(b.nal=1,1.18,1.0)) [sm],
         @nal [nal] 
  --from nearlogistic.bills b
  from nearlogistic.billsSum b
  left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
  left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
  left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
	left join dbo.def f on f.pin=dc.pin
  where b.bill_stack_id=@bill_stack_id and b.casher_id=iif(@casher_id=0,b.casher_id,@casher_id) and b.is_old=iif(@casher_id=0,b.is_old,@is_old) 
  			and b.nal=@nal --case when @nal=0 then 0 when @nal=1 then 1 else b.nal end 
  group by b.casher_id, 'C'+cast(b.bill_stack_id as varchar)+'/'+cast(b.casher_id as varchar), 
  		     isnull(c.casher_name, isnull(fc.ourname,isnull(f.gpname, f.brname)))
  set nocount off       
end