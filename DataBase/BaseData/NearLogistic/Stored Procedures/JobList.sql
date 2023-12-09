CREATE PROCEDURE NearLogistic.JobList
@mhid int
AS
BEGIN
 /*
  select *
 from MARSHJOB 
 where mhid=@mhid
 ORDER BY mjid
  */
  
  if object_id('tempdb..#mh') is not null drop table #mh
  declare @drID int, @nd datetime
  select @drID=drID, @nd=nd from dbo.marsh where mhid=@mhid and drid<>0
  select mhid into #mh
  from [dbo].marsh m 
  where m.drID=@drID and m.nd<=@nd
        
  select j.*,(select fio from usrpwd where uin=j.op) [FIO]
  from dbo.MarshJob j
  where (j.Done in (0,1,2,3) and j.mhid in (select #mh.mhid from #mh)) 
     or j.mhid=@mhid

  if object_id('tempdb..#mh') is not null drop table #mh
END