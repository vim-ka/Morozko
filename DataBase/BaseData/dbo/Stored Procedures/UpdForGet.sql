CREATE  procedure UpdForGet
  @ND datetime, @b_id INT, @Op int, @Pay money, @Rem varchar(50)
as
begin
  insert into ForGet(nd, b_id, op, pay, Rem) values(@nd, @b_id, @op, @Pay, @Rem)
end;