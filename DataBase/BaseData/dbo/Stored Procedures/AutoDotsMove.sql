CREATE PROCEDURE dbo.AutoDotsMove
AS
BEGIN
  declare @ND datetime
  set @ND=dbo.today()-1
  
  /*Перенос точек с Тыщика на агентов*/
  
  create table #White (dck int, ag_id int, PrevAg_ID int) 
    
  insert into #White(dck, ag_id, PrevAg_id)
  select c.dck, c.ag_id, c.Prevag_id 
  from DefContract c 
  where c.ag_id in (33)
        and c.Actual=1
        and c.dck not in 
        (select d.dck from DailySaldoDck d where d.ND=@ND and (d.Deep>=31 or d.overup17>1))

  insert into #White(dck, ag_id, PrevAg_id)
  select c.dck, c.ag_id, c.Prevag_id
  from DefContract c 
  where c.dck in (
    select dck from defcontract where ag_id=33
    except
    select dck from dailysaldodck where nd=@ND
     )
 

  select d.dck, isnull(d.PrevAg_ID,-1) as PrevAg_ID into #WhiteDism from #White w join DefContract d on w.dck=d.dck
                                           left join AgentList a on d.PrevAg_ID=a.Ag_ID
                                           left join person p on a.p_id=p.P_id and p.Closed=0  
  where ISNULL(p.p_id, 0)=0
  
  delete from #White where dck in (select dck from #WhiteDism)

  insert into dbo.MoveDotsLog (dck, ag_id, sv_ag_id, takeoff) 
  select d.dck, a.ag_id, a.sv_ag_id, 0 from #WhiteDism d join agentlist a on d.Prevag_id=a.ag_id

  update defcontract set Ag_id=(select a.Sv_Ag_id from agentlist a where a.ag_id=defcontract.PrevAg_ID)
  where dck in (select dck from #WhiteDism) and ag_id=33 and PrevAg_id is not null

  insert into dbo.MoveDotsLog (dck, ag_id, sv_ag_id, takeoff) 
  select d.dck, d.Prevag_id, a.sv_ag_id, 0 
  from #White d join agentlist a on d.Prevag_id=a.ag_id
  
  update defcontract set Ag_id=PrevAg_id where dck in (select dck from #White) and ag_id=33 and PrevAg_id is not null
  
  delete from dbo.AgAddBases where add_Dck in (select dck from #White) and op=0

  /*Перенос должников на Тыщика*/ --отключена 16.07.2018
  
/*  select c.dck, c.ag_id into #Dolg 
  from DailySaldoDck d join DefContract c on d.dck=c.dck
                       join Def e on c.pin=e.pin 
                       join agentlist a on c.ag_id=a.ag_id
  where d.ND=@ND and d.Deep>=31 and d.overup17>1
        and c.ag_id not in (17,32,33,641) and c.Actual=1 and e.Actual=1 and a.DepID<>3
        and e.Worker=0
        
  insert into dbo.MoveDotsLog (dck, ag_id, sv_ag_id, takeoff) 
  select d.dck, d.ag_id, a.sv_ag_id, 1 from #Dolg d join agentlist a on d.ag_id=a.ag_id
  
  update defcontract set PrevAg_id=Ag_id, Ag_id=33 where dck in (select dck from #Dolg)
  
  insert into dbo.AgAddBases (op,  ag_id,  add_ag_id,  add_Dck) 
  select 0,  l.sv_ag_id,  0,  d.Dck
  from #Dolg d join agentlist l on d.ag_id=l.ag_id
  where not exists (select a.ag_id from dbo.AgAddBases a where a.ag_id=l.sv_ag_id and a.add_Dck=d.dck)
*/
  /*Разблокировка точек*/
  
  select t.dck into #UnlockDebit
  from
  (select c.dck
  from  DefContract c   where c.Actual=1 and c.Debit=1
  except 
  select d.dck from  DailySaldoDck d 
  where d.ND=@ND and d.Deep>17) t
  
  update defcontract set Debit=0 where dck in (select dck from #UnlockDebit)
  
  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', d.pin, 0, getdate(),0, 'Авторазблокировка. Просрочка < 17 дней.'
  from #UnlockDebit t join DefContract c on t.dck=c.dck
                      join Def d on c.pin=d.pin

  select t.dck into #Unlock
  from
  (select c.dck
  from  DefContract c  where c.Actual=1 and c.Disab=1
  except 
  select d.dck from  DailySaldoDck d 
  where d.ND=@ND and d.Deep>2) t
  
  update defcontract set Disab=0 where dck in (select dck from #Unlock)
  
  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', d.pin, 0, getdate(),0, 'Авторазблокировка. Просрочка < 3 дней.'
  from #Unlock t join DefContract c on t.dck=c.dck
                 join Def d on c.pin=d.pin


END