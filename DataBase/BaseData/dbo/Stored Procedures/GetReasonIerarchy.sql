CREATE PROCEDURE dbo.GetReasonIerarchy
AS
BEGIN	
  if object_id('tempdb..#TempReason') is not null drop table #TempReason;

  WITH ReasonRet (Reason_ID, Reason, Parent_ID, Level, pathstr)
  AS
  ( 
    SELECT r.Reason_ID, r.Reason, r.Reason_ID as Parent_ID , 0 AS Level, cast(r.Reason as varchar(2000)) as pathstr
    FROM dbo.ReasonToRtrn AS r
    WHERE r.Parent_ID = 0 and r.isDel=0
    
    UNION ALL

    SELECT r.Reason_ID, r.Reason, r.Parent_ID, Level + 1 as Level, cast(rr.Reason + r.Reason as varchar(2000)) as pathstr
    FROM dbo.ReasonToRtrn AS r
         INNER JOIN ReasonRet AS rr ON r.Parent_ID = rr.Reason_ID
    Where r.isDel=0     
  )


  SELECT Reason_ID, replace(space(level*2),' ','--') + Reason as Reason, pathstr into #TempReason
  FROM ReasonRet
  order by Parent_ID, Level, Reason

  alter table #TempReason add child varchar(2000) not null default ''

  update #TempReason set child = dbo.GetRetReasChild(Reason_ID)


  select * from #TempReason order by pathstr
  
END