CREATE procedure dbo.SaveBuyersDisab
as begin
  update DEF set Debit=0 where Debit=1 and Disab=0;
  
  select c.pin into #Temp005 from defcontract c join PsScores p on c.Degust=p.p_id and p.StID=16 
                                                join Def d on c.pin=d.pin
  where p.Must<30000 and p.OverMust<=0 and d.Disab=1                                                
  
  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', t.pin, 1, getdate(),0, 'Разблокировка по отсутствию долга'
  from #Temp005 t
  
  update DEF set Debit=0, Disab=0 where pin in (select pin from #Temp005);
  
  select c.pin into #Temp004 from defcontract c join PsScores p on c.Degust=p.p_id and p.StID=16 where (p.Must>=30000 or p.OverMust>0)
  
  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', t.pin, 0, getdate(),0, 'Просрочен период списания или превышен лимит ДЕГУСТАЦИИ.'
  from #Temp004 t join Def d on t.pin=d.pin
  where d.disab=0 
   
  update DEF set Disab=1 where pin in (select pin from #Temp004); 
  
  drop table #Temp004;  

  select pin into #Temp003 from defcontract where contrtip=2 and contrnum='' and Nd+20 < GETDATE()  
  
  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', t.pin, 0, getdate(),0, 'Отсутствует договор'
  from #Temp003 t join Def d on t.pin=d.pin
  where d.disab=0 and d.pin<>3434 and d.pin<>20684  and d.pin<>27611 and d.pin<>29988 --Два последних кода по просьбе Кожевникова А. 03.07.15
  and d.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849)
   
  update DEF set Disab=1, Debit=1 where pin in (select pin from #Temp003) and pin<>3434 and pin<>20684    and pin<>27611 and pin<>29988
  and def.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849);
  
  drop table #Temp003;  
  
  select t.pin into #Temp002 from 
  (select distinct b_id as pin from nc
  where 
    nc.b_id>0 and nc.srok>0
    and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
    and nc.ND+15+nc.Srok < GetDate()
    and nc.Actn = 0 and nc.Tara = 0 and NC.Frizer = 0
    and nc.SP>0
    ) t

  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', t.pin, 0, getdate(),0, 'Проср. ДЗ больше 15 дней'
  from #Temp002 t join Def d on t.pin=d.pin
  where d.disab=0 and d.pin<>3434 and d.pin<>20684  and d.pin<>27611 and d.pin<>29988
  and d.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849)
   
  update DEF set Disab=1, Debit=1 where pin in (select pin from #Temp002) and pin<>3434 and pin<>20684  and pin<>27611 and pin<>29988
  and def.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849);
  
  drop table #Temp002;  
  
  select t.pin into #Temp001 from 
  (
  select distinct b_id as pin
  from nc join defcontract d on nc.dck=d.dck
  where 
    nc.b_id>0 and nc.srok>0
    and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
    and ((nc.ND+3+nc.Srok<GetDate() and isnull(d.BnFlag,0)=1) or (nc.ND+1+nc.Srok<GetDate() and isnull(d.BnFlag,0)=0 and NC.ourid not in (10,18))
          or (nc.ND+5+nc.Srok<GetDate() and NC.ourid in (10,18)))
    and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
    and nc.SP>0

  ) t

  insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
  select 'tdmsql', t.pin, 0, getdate(),0, 'Проср. ДЗ больше 5 дней. Для налички больше 1 дня.'
  from #Temp001 t join Def d on t.pin=d.pin
  where d.disab=0 and d.pin<>3434 and d.pin<>20684  and d.pin<>27611 and d.pin<>29988 
    and d.pin<>1066  -- это добавлено 16.06.16 по просьбе Рестории
  and d.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849)
  
  update DEF set Disab=1 where pin in (select pin from #Temp001) and pin<>3434 and pin<>20684  and pin<>27611 and pin<>29988
    and pin<>1066 -- это добавлено 16.06.16 по просьбе Рестории
  and def.master not in (598,435,1944,1167,312,7503,11015,15144,9758,20248,8878, 8074,2176,14436,10092, 14476, 26901,29284,34485,43849);


  drop table #Temp001;
  
  
             
  --обновление мастер-договора отключено
 /* update defcontract set dckmaster=(select min(c.dck) from defcontract c join def d on  c.pin=d.master and c.contrtip=2 
  where d.master<>0 and c.ContrName=defcontract.ContrName and c.our_id=defcontract.our_id and d.pin=defcontract.pin)
  where dck in (select c.dck from defcontract c join def d on  c.pin=d.pin and c.contrtip=2 
                where d.master<>0)
 */ 
end;