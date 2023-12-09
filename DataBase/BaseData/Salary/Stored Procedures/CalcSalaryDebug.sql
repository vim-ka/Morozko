CREATE procedure Salary.CalcSalaryDebug @day0 datetime, @day1 datetime, 
  @RecalcMode varchar(20), -- режим пересчета:
  -- "Full" - полный, "Pay" - только выплат.
  @Cname varchar(20), @yy int, @mm int
as
declare @s2id int, @nom0 int, @nom1 int
begin
  set @nom0=dbo.InDatNom(1, @day0);
  set @nom1=dbo.InDatNom(9999, @day1);  
  set @s2id = (select s2id from Salary.Salary2main where day0=@day0 and day1=@day1 and Cancelled=0);
  if isnull(@s2id,0)=0 begin
    set @RecalcMode='Full';
    insert into Salary.Salary2main(day0,day1,cname) values(@day0,@day1,@cname);
    set @s2id = SCOPE_IDENTITY();
  end;
  
  if not exists(select * from Salary2agentlist) set @RecalcMode='Full';

  -- Какие выплаты нужно учесть в расчете?  
  
  
  
  create table #t(datnom int, dck int, b_id int, ag_id int, plata decimal(12,2), 
    SP decimal(12,2), SC decimal(12,2), part decimal(15,8) default 1, Extra decimal(6,2));
  insert into #t(datnom, dck, b_id, ag_id, plata,sp,sc, extra)
    select k.sourdatnom as datnom, nc.dck, k.b_id, dc.Ag_Id, sum(k.plata) as Plata,
      nc.sp, nc.sc, nc.extra
    from 
      kassa1 k 
      inner join nc on k.sourdatnom=nc.datnom
      inner join defcontract dc on dc.dck=nc.dck
    where k.oper=-2 and k.nd between @day0 and @day1
    and nc.actn=0 and nc.tara=0 and nc.frizer=0
    group by k.sourdatnom, nc.dck, k.b_id, dc.Ag_Id,  nc.sp, nc.sc, nc.extra;
  
  update #t set part=plata/sp where sp<>0;
  
  create index tmp_idx on #t(datnom);
  
  -- Какие расходные накладные (без выплат!) нужно еще учесть в расчете?
  insert into #t(datnom, dck, b_id, ag_id, plata,sp,sc, extra,part)
  select nc.datnom, nc.dck, nc.B_ID, dc.ag_id, 0 as Plata,  nc.sp, nc.sc, nc.extra,0
  from 
    nc 
    inner join defcontract dc on dc.dck=nc.dck
  where
    nc.nd between @day0 and @day1
    and nc.Actn=0 and nc.tara=0 and nc.Frizer=0
    and nc.datnom not in (select datnom from #t)
      -- (select distinct sourdatnom from kassa1 k where k.oper=-2 and k.nd between @day0 and @day1)

-- delete from #t where b_id not in (971,973,974) or datnom<141101000 or datnom>1411309999;
--  select * from #t where b_id in (971,973,974) and datnom between 1411010001 and 1411309999;
--  select sum(sp) from #t where b_id in (971,973,974) and datnom between 1411010001 and 1411309999;
--  select * from #t;


  if @RecalcMode='Full' begin
    -- В список покупателей запихнем еще дебиторку и просрочку:
-- ОТКЛЮЧЕНО ДЛЯ ОТЛАДКИ:    exec SaveDailySaldoDCK @day1;  
    
    delete from salary.Salary2buyersDebug where s2id=@s2id;
    
    insert into salary.Salary2buyersDebug(s2id, b_id, dck, ag_id,debt, overdue, overup17, Plata, Sell)
      select @s2id as s2id, #t.b_id, #t.dck, #t.ag_id,ds.debt, ds.Overdue, ds.overup17,
        sum(#t.plata) Plata, 
        sum(case when #t.datnom between @nom0 and @nom1 then #t.sp else 0.0 end) sell
      from 
        #t 
        left join DailySaldoDck ds on ds.dck=#t.dck and ds.nd=@day1
      group by
        #t.b_id, #t.dck, #t.ag_id,ds.debt, ds.Overdue, ds.overup17;

        
    delete from salary.Salary2agentlistDebug where s2id=@s2id;
    
    insert into Salary.Salary2agentlistDebug(s2id, ag_id, AgentFam, sv_Ag_ID, DepID)
    select distinct
      @s2id, A.ag_id, p.fio as AgentFam, a.sv_ag_id, Sv.depId 
    from 
      salary.Salary2buyersDebug b
      inner join Agentlist A on a.ag_id=b.ag_id
      inner join Person P on p.p_id=a.p_id
      inner join agentlist sv on sv.ag_id=a.sv_Ag_ID
    where b.s2id=@s2id;
    
    delete from salary.Salary2superlistDebug where s2id=@s2id;

    insert into Salary.Salary2superlistDebug(s2id, sv_ID, SuperFam, DepID)
    select distinct
      @s2id, sv.ag_id as sv_iD, p.fio as SuperFam, Sv.depId 
    from 
 	  Salary.Salary2agentlistDebug A
      inner join agentlist sv on sv.ag_id=a.sv_Ag_ID
      inner join Person P on p.p_id=sv.p_id
    where a.s2id=@s2id;
    
    
    
    /*
    select 
      @s2id,
      sv.DepID, Deps.dname,
      a.sv_ag_id as SV_id, 
      -- sv.AgentFam as SuperFam,
      '' as SuperFam,
      #t.ag_id, a.AgentFam,    
      #t.b_id, #t.dck, Def.gpName,
      b.plata, --  sum(#t.plata) as Plata,
      sum(#t.part*nv.kol*(NV.Price*(1.0+#t.extra/100) - nv.Cost)) as Dohod,
      sum(#t.part*isnull(m.part,1)*0.1*nv.kol*(NV.Price*(1.0+#t.extra/100) - nv.Cost)) as Kopl,
      b.Sell
    from 
      #t 
      inner join nv on #t.datnom=nv.datnom
      inner join salary.Salary2agentlist a on a.ag_id=#t.ag_id
      -- inner join salary.Salary2agentlist sv on sv.ag_id=a.sv_ag_id
      inner join agentlist sv on sv.ag_id=a.sv_ag_id
      inner join Deps on Deps.DepID=sv.depId
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join GR on GR.Ngrp=nm.ngrp
      left  join Salary.agentmatrix m on  gr.MainParent=m.ngrp and m.ag_id=#t.ag_id and m.yy=2013 and m.mm=@MM 
      inner join Def on Def.pin=#t.b_id
      left  join salary.Salary2buyers b on b.dck=#t.dck and b.b_id=#t.b_id
    where
      a.s2id=@s2id
      and b.s2id=@s2id
      -- and sv.s2id=@s2id
    group by
      sv.DepID, Deps.dname, a.sv_ag_id, 
      -- sv.AgentFam, 
      #t.ag_id, a.AgentFam,
      #t.b_id, #t.dck, Def.gpName, b.plata,b.Sell
      */

  -- Это всё ещё фигня, теперь перейдем к выплатам и доходу:

  if @RecalcMode<>'none' begin
    delete from Salary.Salary2resultDebug where s2id=@s2id; 

    insert into salary.Salary2resultDebug
    select 
      @s2id,
      sv.DepID, Deps.dname,
      a.sv_ag_id as SV_id, 
      sv.SuperFam,
      #t.ag_id, a.AgentFam,    
      #t.b_id, #t.dck, Def.gpName,
      b.plata, --  sum(#t.plata) as Plata,
      sum(#t.part*nv.kol*(NV.Price*(1.0+#t.extra/100) - nv.Cost)) as Dohod,
      sum(#t.part*isnull(m.part,1)*0.1*nv.kol*(NV.Price*(1.0+#t.extra/100) - nv.Cost)) as Kopl,
      b.Sell
    from 
      #t 
      inner join nv on #t.datnom=nv.datnom
      inner join salary.Salary2agentlist a on a.ag_id=#t.ag_id
      inner join salary.Salary2superlistDebug sv on sv.sv_id=a.sv_ag_id
      inner join Deps on Deps.DepID=sv.depId
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join GR on GR.Ngrp=nm.ngrp
      left  join Salary.agentmatrix m on  gr.MainParent=m.ngrp and m.ag_id=#t.ag_id and m.yy=2013 and m.mm=@MM 
      inner join Def on Def.pin=#t.b_id
      left  join salary.Salary2buyers b on b.dck=#t.dck and b.b_id=#t.b_id
    where
      a.s2id=@s2id
      and b.s2id=@s2id
      and sv.s2id=@s2id
    group by
      sv.DepID, Deps.dname, a.sv_ag_id, 
      sv.SuperFam,
      #t.ag_id, a.AgentFam,
      #t.b_id, #t.dck, Def.gpName, b.plata,b.Sell
  end;
  
  -- Возможно, список супервайзеров всё равно придется обновить, например, для
  -- прошлых месяцев, где он в предыдущей версии алгоритма не использовался вообще:
  if not exists(select * from salary.Salary2superlistDebug where s2id=@s2id)
    insert into Salary.Salary2superlistDebug(s2id, sv_ID, SuperFam, DepID)
    select distinct
      @s2id, sv.ag_id as sv_iD, p.fio as SuperFam, Sv.depId 
    from 
 	  Salary.Salary2agentlistDebug A
      inner join agentlist sv on sv.ag_id=a.sv_Ag_ID
      inner join Person P on p.p_id=sv.p_id
    where a.s2id=@s2id;
  
--  select * from salary.salary2resultDebug;
  select @s2id;

end;

END