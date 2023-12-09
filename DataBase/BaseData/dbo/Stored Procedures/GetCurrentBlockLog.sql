CREATE PROCEDURE dbo.GetCurrentBlockLog
@TekID int
AS 
select *,
			 (select fio from usrpwd where uin=op) [opname],
       (select fio from person where p_id=l.p_id) [usname],
       (case when l.LockFlag=0 then 'разблокировка'
       			 when l.LockFlag=1 then 'блокировка'
             when l.LockFlag=2 then 'продление' end) [locktxt],
       (select LockReason.lrName from LockReason where LockReason.lrID=l.lrID) [reason]
from [locklog] l
where l.id=@TekID
order by l.nd desc, l.tm desc