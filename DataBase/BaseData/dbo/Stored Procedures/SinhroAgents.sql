CREATE procedure SinhroAgents
as
declare @P_id int, @ag_id int, @Sv_id int
declare @Fio varchar(100)
begin

  set @P_id = 0 

  /*declare CR cursor fast_forward for 
  select P_id, Fio from Person
  where Agent=1 and isnull(Ag_id,0)=0
  order by P_ID;
  open CR;
  
  fetch next from CR into @P_ID, @Fio;
  
  while (@@FETCH_STATUS=0)
  begin
    insert into Agents (Fam) values(SUBSTRING(@Fio,1,50));
    set @Ag_id=SCOPE_IDENTITY();
    update Person set ag_id=@ag_id where P_ID=@p_id;
    
    insert into AgentList (Agent,Ag_id,P_id,SkipSver,TmrEnab,Sklad,OrdStick) 
                    values('ppc'+cast(@P_id as varchar),@ag_id,@P_id,0,0,0,0);
	fetch next from CR into @P_ID, @Fio;
  end;
  
  close CR;
  DEALLOCATE CR;
    
  declare CR cursor fast_forward for 
    select P_id, Fio from Person
    where Supervis=1 and isnull(Sv_id,0)=0
    order by P_ID;
  open CR;
  
  fetch next from CR into @P_ID, @Fio;
  
  while (@@FETCH_STATUS=0) begin
    insert into Supervis(Fam) values(SUBSTRING(@Fio,1,50));
    set @Sv_id=SCOPE_IDENTITY();
    update Person set Sv_id=@Sv_id where P_ID=@p_id;
	fetch next from CR into @P_ID, @Fio;
  end;
  
  close CR;
  DEALLOCATE CR;
  
  update supervis set DepID=isnull((select p.DepID from person p where p.sv_id=SuperVis.sv_id and p.supervis=1),0)
  update person set sv_id=isnull((select p.sv_id from person p where p.supervis=1 and p.p_id=Person.svp_id),0) where agent=1
  --update agents set sv_id=isnull((select p.sv_id from person p where p.ag_id=agents.ag_id and p.agent=1),0)
  */
end;