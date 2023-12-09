create procedure guard.PrepDblWorkers @ND datetime
as
begin
  select pin, who1, P1.Fio as Worker1, who2, P2.Fio as worker2
  from (
      select pin, 
        min(ag_ID) as Who1, 
        MAX(ag_ID) as Who2
      from rests
      where NeedDay = @ND and ag_id>0
      group by pin
      having min(ag_ID)<MAX(ag_ID)
      ) E
  left join Agentlist A1 on a1.ag_id=who1
  left join Person P1 on P1.p_id=A1.p_id
  left join Agentlist A2 on a2.ag_id=who2
  left join Person P2 on P2.p_id=A2.p_id
end;