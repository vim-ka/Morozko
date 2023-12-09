CREATE procedure AddSSmain(@MarshDay datetime, @Marsh int, @op int, @NOMER int out)
as 
begin
  insert into SSmain(ND, TM, MarshDay, Marsh, Op, Done)
  values(  convert(char(10), getdate(),104), convert(char(8), getdate(),108),
    @MarshDay, @Marsh, @op,0);
  set @NOMER=@@IDENTITY;  
  select @NOMER;
end;