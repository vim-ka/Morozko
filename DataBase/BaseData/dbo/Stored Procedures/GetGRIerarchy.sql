CREATE PROCEDURE dbo.GetGRIerarchy
AS
BEGIN	
  --declare @ngrp int
  --declare @child varchar(2000);
  
  with GRReport (ngrp, grpname, level, pathstr)
  as (select ngrp,grpname,0,cast(grpname as varchar(2000))
      from gr 
      where ngrp<>0 and parent=0 and gr.aginvis=0
          
      union all 
      
      select gr.ngrp,gr.grpname,grreport.level+1,cast(grreport.pathstr+Gr.GrpName as varchar(2000))
      from gr
      inner join GRReport on grreport.ngrp=gr.parent
      where gr.ngrp<>0 and gr.aginvis=0      
      )
  select ngrp,replace(space(level*2),' ','-')+grpname [grpname],pathstr
  into #res
  from GRReport    
  order by pathstr
  
  select * into #gr from (
  select -1 [ngrp], 'Все группы' [grpname], '' as pathstr
  union all
  select * from #res) x
  
  create nonclustered index idx_tgr on #gr(ngrp)
  
  alter table #gr add child varchar(2000) not null default ''
  
  update #gr set child=dbo.GetGrChild(ngrp)
  where ngrp>0
  
  select * from #gr order by pathstr 
  
  drop table #res
  drop table #gr

END