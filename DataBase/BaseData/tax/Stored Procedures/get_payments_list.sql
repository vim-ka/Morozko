CREATE procedure tax.get_payments_list
@job_id int
as
begin
  select p.payment_id, p.nd, p.payment, 
         (select sum(plata) from dbo.kassa1 where b_id=j.pin and p.nd=iif(bank_id>0,bankday,nd)) [kassa], 
         p.isdel
  from tax.job j
  join tax.payments p on p.job_id=j.job_id
  where j.job_id=@job_id
  order by p.nd desc
end