create function dbo.get_real_agent (@ag_id int, @nd datetime)
returns @res table(p_id int, depid int)
as
begin
	insert into @res
	select top 1 p_id,depid from (
	select top 1 h.p_id, h.depid, 0 [ord]
  from dbo.agentlisthistory h
  where h.ag_id=@ag_id and h.ndclose<=@nd
  union
  select p_id, depid,1
  from dbo.agentlist a 
  where a.ag_id=@ag_id) z
  order by z.[ord]
  
  return	
end