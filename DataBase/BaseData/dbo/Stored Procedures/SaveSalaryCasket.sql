create procedure SaveSalaryCasket @yy int, @mm int, @ag_id INT, @Casket decimal(10,2)
as
begin
  if @casket=0 delete from SalaryCasket where yy=@yy and mm=@mm and ag_id=@ag_id;
  else BEGIN
    if EXISTS(select * from SalaryCasket where yy=@yy and mm=@mm and ag_id=@ag_id) 
    update SalaryCasket set Casket=@Casket where yy=@yy and mm=@mm and ag_id=@ag_id;
    else insert into SalaryCasket(yy,mm,ag_id,Casket) values(@yy,@mm,@ag_id,@Casket);
  end;
end