CREATE procedure warehouse.terminal_CheckManagerSPK
@spk int
as 
begin
	select x.[res], iif(x.[res]=0,'В доступе отказано','') [msg] 
  from (
  select cast(iif(@spk in (select spk from dbo.skladpersonal where trid=38 and closed=0),1,0) as bit) [res]) x
end