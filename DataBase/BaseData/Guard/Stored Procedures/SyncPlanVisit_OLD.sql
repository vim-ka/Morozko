

CREATE PROCEDURE [Guard].SyncPlanVisit_OLD
AS
BEGIN

truncate table PlanVisit2

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,1, dt1, dck, tip1
from planvisit
where dt1 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,2, dt2, dck, tip2
from planvisit
where dt2 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,3, dt3, dck, tip3
from planvisit
where dt3 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,4, dt4, dck, tip4
from planvisit
where dt4 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,5, dt5, dck, tip5
from planvisit
where dt5 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,6, dt6, dck, tip6
from planvisit
where dt6 <> 0

insert into PlanVisit2(pin, ag_id, dn, tm, dck, tip)
select pin, ag_id,7, dt7, dck, tip7
from planvisit
where dt7 <> 0

END