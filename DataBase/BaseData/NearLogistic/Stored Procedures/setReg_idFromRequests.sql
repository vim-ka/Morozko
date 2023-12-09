create procedure nearlogistic.setReg_idFromRequests @reqs varchar(5000), @regionid int, @op int
as
begin
declare @reg_id varchar(5)
select @reg_id=reg_id from dbo.regions where regionid=@regionid

update p set p.reg_id=@reg_id
from nearlogistic.marshrequests_points p 
join (
 select d.point_id
 from string_split(@reqs,'#') s
 join nearlogistic.marshrequestsdet d on d.mrfid=s.value and d.action_id=6) x on x.point_id=p.point_id
end