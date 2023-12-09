CREATE procedure dbo.SaveContractDisab
as begin
  update defcontract set Debit=0 where Debit=1 and Disab=0;
  
  select c.dck into #DCKException 
  from defcontract c join def d on c.pin=d.pin
  where c.ContrTip=2 and c.Actual=1 and d.Actual=1 
  and (d.master in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 27124, 26901,29284,34485,43849,55178)
  or d.pin in (3434, 20684, 27611, 29988, --Два последних кода по просьбе Кожевникова А. 03.07.15
    1066,55178)) -- это добавлено 16.06.16 по просьбе Рестории
  
  
  select c.dck into #Temp005 from defcontract c join PsScores p on c.Degust=p.p_id and p.StID=16 
                                                join Def d on c.pin=d.pin
  where p.Must<30000 and p.OverMust<=0 and c.Disab=1                                                
  
  insert into #Temp005 (dck)
  select c.dck from defcontract c join def d on c.pin=d.pin 
  where c.Actual=1 and (c.Disab=1 or c.Debit=1)                                               
        and (isnull(c.contrnum,'')<>'' or c.Nd+20 > GETDATE() or d.worker=0)
        and c.dck not in 
        (select distinct d.DCK
         from nc join defcontract d on nc.dck=d.dck
         where 
          nc.b_id>0 and nc.srok>0
          and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
          and ((nc.ND+5+nc.Srok<GetDate() and isnull(d.BnFlag,0)=1) or (nc.ND+2+nc.Srok<GetDate() and isnull(d.BnFlag,0)=0))
          and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
          and nc.SP>0) 

  
  insert into dbo.EnabLog (CompName, B_ID, DCK, Enab, CheckDate, OP, Comment) 
  select 'tdmsql',c.pin,c.DCK, 0, getdate(),0, 'Разблокировка по отсутствию долга'
  from #Temp005 t join DefContract c on t.dck=c.dck
  
  update Defcontract set Debit=0, Disab=0 where dck in (select dck from #Temp005);
  
  select c.dck into #Temp004 from defcontract c join PsScores p on c.Degust=p.p_id and p.StID=16 where (p.Must>=30000 or p.OverMust>0)
  
  insert into dbo.EnabLog (CompName, B_ID, DCK, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', c.pin,t.DCK, 1, getdate(),0, 'Просрочен период списания или превышен лимит ДЕГУСТАЦИИ.'
  from #Temp004 t join DefContract c on t.DCK=c.DCK
  where c.disab=0 
   
  update DefContract set Disab=1 where dck in (select dck from #Temp004); 
  
  drop table #Temp004;  

  select c.dck into #Temp003 from defcontract c join def d on c.pin=d.pin where c.contrtip=2 and isnull(c.contrnum,'')='' and c.Nd+20 < GETDATE() and d.worker=0 
  
  insert into dbo.EnabLog (CompName, B_ID, DCK, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', d.pin, t.DCK, 1, getdate(),0, 'Отсутствует договор'
  from #Temp003 t join DefContract d on t.dck=d.dck
  where d.disab=0 and d.DCK not in (select DCK from #DCKException)
   
  update DefContract set Disab=1, Debit=1 where dck in (select dck from #Temp003) and DCK not in (select DCK from #DCKException)
  
  drop table #Temp003;  
  
  select t.dck into #Temp002 from 
  (select distinct nc.dck as dck from nc
  where 
    nc.b_id>0 and nc.srok>0
    and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
    and nc.ND+15+nc.Srok < GetDate()
    and nc.Actn = 0 and nc.Tara = 0 and NC.Frizer = 0
    and nc.SP>0
    ) t

  insert into dbo.EnabLog (CompName, B_ID, DCK, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', d.pin, t.dck, 1, getdate(),0, 'Проср. ДЗ больше 15 дней'
  from #Temp002 t join DefContract d on t.dck=d.dck
  where d.disab=0 and d.DCK not in (select DCK from #DCKException)
   
  update DefContract set Disab=1, Debit=1 where dck in (select dck from #Temp002) and DCK not in (select DCK from #DCKException)
  
  drop table #Temp002;  
  
  select t.DCK into #Temp001 from 
  (
  select distinct d.DCK as DCK
  from nc join defcontract d on nc.dck=d.dck
  where 
    nc.b_id>0 and nc.srok>0
    and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
    and ((nc.ND+5+nc.Srok<GetDate() and isnull(d.BnFlag,0)=1) or (nc.ND+2+nc.Srok<GetDate() and isnull(d.BnFlag,0)=0))
    and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
    and nc.SP>0

  ) t

  insert into dbo.EnabLog (CompName, B_ID, DCK, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', d.pin, d.DCK, 1, getdate(),0, 'Проср. ДЗ больше 5 дней. Для налички больше 1 дня.'
  from #Temp001 t join DefContract d on t.dck=d.dck
  where d.disab=0 and d.DCK not in (select DCK from #DCKException)
  
  update DefContract set Disab=1 where dck in (select dck from #Temp001) and DCK not in (select DCK from #DCKException)


  drop table #Temp001;
  drop table #DCKException;        
 
end;