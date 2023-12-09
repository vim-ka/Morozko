create procedure Salary.CheckAgentMatrix @yy int
as
declare @ag_id int;
begin
  
  declare c1 cursor fast_forward for 
  select distinct ag.ag_id
  from 
    agentlist ag 
    inner join agentlist sv on sv.ag_id=ag.sv_ag_id
    inner join deps on deps.depid=sv.depid
    inner join Person P on P.p_id=ag.p_id and P.fio is not null
  where deps.Sale=1
  order by ag.ag_id;
  
  open c1;
  fetch next from c1 into @ag_id;
  while (@@FETCH_STATUS=0) BEGIN
    if not EXISTS(select * from AgentMatrix where yy=@yy and ag_id=@ag_id) begin
    
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 1 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 2 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 3 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 4 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 5 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 6 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 7 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 8 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 9 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 10 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 11 as mm, @ag_id, mainparent from GR order by mainparent;
      
      insert into AgentMatrix(yy,mm,ag_id,ngrp) 
      select distinct @yy as yy, 12 as mm, @ag_id, mainparent from GR order by mainparent;
    end;
    
    fetch next from c1 into @ag_id;
  end;
  close C1;
  deallocate C1;
end;