create procedure SaveFrizAct @op int, @ag_id int, @ActId int out
as
begin
  insert into FrizAct(op, ag_id) values(@op, @ag_id);
  set @ActId=SCOPE_IDENTITY();
  select @ActId;  
end;