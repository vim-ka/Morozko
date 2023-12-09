CREATE procedure Guard.PrepDblControl @ND datetime, @Part smallint=1
as
begin
  -- Таблица повторяющихся сверок:
create table #dbl(pin int, Who1 int, Who2 int);
insert into #dbl
  select pin, min(ag_ID) as Who1, MAX(ag_ID) as Who2
  from rests 
  where NeedDay = @nd and ag_id>0
  group by pin
  having min(ag_ID)<MAX(ag_ID);

create index d_id1_idx on #dbl(who1);

  -- Собственно таблица для сверки:
if @Part=1
  select
    SV.DepID, Deps.DName,
    ag.sv_ag_id as sv_id, 
    PS.Fio as sv_Fam,
    dc.ag_id,  PA.fio as ag_Fam, 
    r.pin, def.gpName,
    r.hitag, nm.[name], R.AG_ID as WrkID, PW.Fio as Worker, r.qty as Rest, gn.MinRest
  from 
    rests r
    inner join #dbl on r.ag_id=#dbl.who1 and r.pin=#dbl.pin
    inner join defcontract dc on dc.pin=r.pin and dc.dck=r.dck
    inner join Def on Def.pin=r.pin
    inner join Agentlist AG on AG.ag_id=dc.ag_id
    inner join Person PA on PA.p_id=Ag.p_id
    inner join AgentList SV on SV.AG_ID=AG.sv_ag_id
    inner join Person PS on PS.p_id=SV.p_id
    inner join Deps on Deps.DepID=SV.DepID
    inner join Nomen nm on nm.hitag=r.hitag
    inner join Agentlist WR on WR.ag_id=r.ag_id
    inner join Person PW on PW.p_id=WR.p_id
    left join [Guard].Normativ GN on GN.pin=r.pin and GN.Hitag=r.Hitag
  where 
    r.NeedDay=@nd
    ;
else if @Part=2
  select
    SV.DepID, Deps.DName,
    ag.sv_ag_id as sv_id, 
    PS.Fio as sv_Fam,
    dc.ag_id,  PA.fio as ag_Fam, 
    r.pin, def.gpName,
    r.hitag, nm.[name], R.AG_ID as WrkID, PW.Fio as Worker, r.qty as Rest, gn.minrest
  from 
    rests r
    inner join #dbl on r.ag_id=#dbl.who2 and r.pin=#dbl.pin
    inner join defcontract dc on dc.pin=r.pin and dc.dck=r.dck
    inner join Def on Def.pin=r.pin
    inner join Agentlist AG on AG.ag_id=dc.ag_id
    inner join Person PA on PA.p_id=Ag.p_id
    inner join AgentList SV on SV.AG_ID=AG.sv_ag_id
    inner join Person PS on PS.p_id=SV.p_id
    inner join Deps on Deps.DepID=SV.DepID
    inner join Nomen nm on nm.hitag=r.hitag
    inner join Agentlist WR on WR.ag_id=r.ag_id
    inner join Person PW on PW.p_id=WR.p_id
    left join [Guard].Normativ GN on GN.pin=r.pin and GN.Hitag=r.Hitag
  where 
    r.NeedDay=@nd
    ;
else
  select
    SV.DepID, Deps.DName,
    ag.sv_ag_id as sv_id, 
    PS.Fio as sv_Fam,
    dc.ag_id,  PA.fio as ag_Fam, 
    r.pin, def.gpName,
    r.hitag, nm.[name], R.AG_ID as WrkID, PW.Fio as Worker, r.qty as Rest, gn.minrest
  from 
    rests r
    inner join defcontract dc on dc.pin=r.pin and dc.dck=r.dck
    inner join Def on Def.pin=r.pin
    inner join Agentlist AG on AG.ag_id=dc.ag_id
    inner join Person PA on PA.p_id=Ag.p_id
    inner join AgentList SV on SV.AG_ID=AG.sv_ag_id
    inner join Person PS on PS.p_id=SV.p_id
    inner join Deps on Deps.DepID=SV.DepID
    inner join Nomen nm on nm.hitag=r.hitag
    inner join Agentlist WR on WR.ag_id=r.ag_id
    inner join Person PW on PW.p_id=WR.p_ID
    left join [Guard].Normativ GN on GN.pin=r.pin and GN.Hitag=r.Hitag
  where 
    r.NeedDay=@nd
    and r.pin not in (select pin from #dbl)
    ;
    
end ;