CREATE procedure CopyPlan 
 @oldAg_id int, @ag_id int
as
begin
  insert into PlanVisit (pin,ag_id,dt1,dt2,dt3,dt4,dt5,dt6,dt7)
  select pin,@ag_id,dt1,dt2,dt3,dt4,dt5,dt6,dt7 from PlanVisit where ag_id=@oldAg_id
end;