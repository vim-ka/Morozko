CREATE PROCEDURE warehouse.terminal_GetPhotoPath
@reqretid int
AS
BEGIN
declare @dck int
declare @ag_id int 
declare @nd datetime 

select @dck=r.dck, @ag_id=q.ag_id, @nd=r.ret_nd
from dbo.requests q
join dbo.reqreturn r on r.reqnum=q.rk
--join dbo.reqreturndet d on d.reqretid=r.reqnum
--where d.id=@reqretdetid
where r.reqnum=@reqretid
group by r.dck, q.ag_id, r.ret_nd

select fmp.mpID 
from Guard.FMonitor fm 
inner join Guard.FMonitorPics fmp on fmp.fmID = fm.fmID 
where fm.DCK = @dck and fmp.Grp = 10 and fm.ag_id = @ag_id and fm.nd = @nd
END