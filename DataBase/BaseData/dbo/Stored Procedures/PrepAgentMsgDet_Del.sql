

CREATE procedure PrepAgentMsgDet_Del @NeedDay datetime, @ag_id int
as 
begin
  create table #t (b_id int, gpname varchar(100), StopDate datetime);
  
  insert into #t
  select distinct nc.B_ID, def.gpname, @NeedDay 
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where dc.ag_id=@ag_id and nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@NeedDay;
  
  insert into #t
  select distinct nc.B_ID, def.gpname, @NeedDay+1 
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where dc.ag_id=@ag_id and nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@NeedDay+1
  and nc.b_id not in (select b_id from #t);
  
  insert into #t
  select distinct nc.B_ID, def.gpname, @NeedDay+2
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where dc.ag_id=@ag_id and nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@NeedDay+2
  and nc.b_id not in (select b_id from #t);
  
  select * from #t order by StopDate, b_id;
end;