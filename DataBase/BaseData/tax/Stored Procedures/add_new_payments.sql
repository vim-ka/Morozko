create procedure tax.add_new_payments
@nd datetime, @pay money, @job_id int, @op int
as
begin
	insert into tax.payments(nd,payment,job_id,op)
  values(@nd,@pay,@job_id,@op)
end