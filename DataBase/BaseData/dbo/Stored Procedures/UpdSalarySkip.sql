create procedure UpdSalarySkip @yy int, @mm int, @b_id int, @Skip bit
as 
begin
  if (@Skip=0) begin
	 if Exists(Select * from SalarySkip where yy=@yy and mm=@mm and b_id=@b_id)
     delete from SalarySkip where yy=@yy and mm=@mm and b_id=@b_id;
  end;
  else begin
    if not Exists(Select * from SalarySkip where yy=@yy and mm=@mm and b_id=@b_id)
    insert into SalarySkip(yy,mm,b_id) VALUES(@yy, @mm, @b_id);
  end;
end;