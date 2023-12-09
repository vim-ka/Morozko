create function dbo.get_real_agent_info (@ag_id int, @nd datetime, @type int)
returns int
as begin
declare @res int

select @res=case when @type=1 then x.p_id
  								 when @type=2 then x.depid end
from (
  select top 1 p_id,depid from (
    select top 1 h.p_id, h.depid, 0 [ord]
    from dbo.agentlisthistory h
    where h.ag_id=@ag_id and h.ndclose<=@nd
    union
    select p_id, depid,1
    from dbo.agentlist a 
    where a.ag_id=@ag_id) z
  order by z.[ord]
) x

return @res
end