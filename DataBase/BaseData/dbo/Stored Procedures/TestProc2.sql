CREATE procedure TestProc2
as
begin
  begin tran
  update __sass1 set kol=kol+1
  commit
end