create procedure Salary.CheckAgentBase
as
declare @ag_id int, @depid int
begin
  -- Список групп старшего уровня (на начало февраля 2017 года их было 19 штук):
  create table #G(Ngrp int);
  insert into #G
    select distinct gr.MainParent 
    from gr inner join gr as g2 on g2.ngrp=gr.MainParent;

  -- Список действующих агентов:
  create table #ag(ag_id int, DepID int);
  insert into #ag 
    select distinct a.ag_id, sv.depid
    from 
      agentlist a 
      inner join agentlist sv on sv.AG_ID=a.sv_ag_id
      inner join person p on p.p_id=a.AG_ID
      -- inner join Defcontract DC on dc.ag_id=a.AG_ID
    where 
     p.Closed=0;
   -- Список месяцев года:
   create table #mm (mm smallint);
   insert into #mm select k from dbo.Str2intarray('1,2,3,4,5,6,7,8,9,10,11,12');



	DECLARE c1 CURSOR READ_ONLY FAST_FORWARD LOCAL FOR
    select e.ag_id, sv.depid
    from (  select distinct ag_id from #ag 
            except
            select distinct ag_id from salary.agentmatrix
         ) E
    inner join AgentList a on a.ag_id=e.ag_id
    inner join AgentList sv on sv.ag_id=a.sv_ag_id
  OPEN c1;
   
  FETCH NEXT FROM c1 INTO @ag_id, @DepID;
  WHILE @@FETCH_STATUS = 0 BEGIN  
    print('Ag_ID='+cast(@ag_id as varchar)+',  DepID='+cast(@depid as varchar));

    insert into salary.agentmatrix(yy,mm,ag_id,ngrp,part)
    select 2013, #mm.mm, @ag_id, #g.ngrp, 0.7 as part
    from #mm, #G

    FETCH NEXT FROM c1 INTO @ag_id, @DepID;
  END;
  close c1;
  deallocate c1;
end;