CREATE procedure CalcSectorBase @day0 datetime, @day1 datetime, @DepID int
as
begin
  create table #t(datnom int not null primary key, 
    b_id int, fam varchar(35), dck int, extra decimal(6,2),
    SP decimal(12,2), SC decimal(15,5),
    Plata decimal(12,2), PayKoeff decimal(15,7));
  
  insert into #t(datnom, b_id,fam,dck,Extra, sp,sc,plata)
  select 
    k.SourDatnom as datnom, nc.b_id, nc.fam,NC.dck,nc.extra, 
    nc.sp, nc.SC, sum(k.plata) as Plata
  from kassa1 k inner join nc on nc.datnom=k.sourdatnom
  where k.nd between @day0 and @day1 and k.oper=-2
  and nc.actn=0 and NC.tara=0-- and nc.Frizer=0
  -- AND k.sourdatnom=1310280008 and k.nd='20131029' -- ЭТО для отладки!
  group by k.SourDatnom, nc.b_id, nc.fam, nc.dck, nc.extra,nc.sp, nc.SC;
  
  update #t set PayKoeff=plata/sp where sp<>0;

  select 
    e.AG_ID,  e.Fio, e.AgentPart, 
    e.b_id, e.BrFam,
    e.MainParent,e.GrpName,
    sum(e.GroupSP) as GroupSP,
    sum(e.GroupPlata) as GroupPlata,
    sum(e.GroupDohod) as GroupDohod
  from (
    select 
      al.Agentpart, #t.sp, #t.PayKoeff, al.AG_ID, #t.b_id, max(#t.fam) as BrFam, 
      P.Fio, gr.MainParent, G2.GrpName,
      ROUND(SUM(nv.kol*nv.Price*(1.0+#t.Extra/100.0)),2) as GroupSP,
  --    ROUND(SUM(nv.kol*nv.Cost),2) as GroupSC,
  --    ROUND(SUM(nv.kol*nv.Price*(1.0+#t.Extra/100.0))/#t.sp,8) as GroupPart,
      ROUND(#t.PayKoeff*SUM(nv.kol*nv.Price*(1.0+#t.Extra/100.0)),5) as GroupPlata,
      ROUND(#t.PayKoeff*SUM(nv.kol*(nv.Price*(1.0+#t.Extra/100.0)-nv.cost)),5) as GroupDohod
    from 
      #t 
      inner join nv on nv.datnom=#t.datnom
      inner join nomen nm on nm.hitag=nv.Hitag
      inner join GR on Gr.ngrp=nm.ngrp
      inner join Gr G2 on G2.ngrp=Gr.MainParent
      inner join Defcontract DC on dc.DCK=#t.dck
      inner join Agentlist AL on AL.AG_ID=dc.ag_id
      inner join Person P on P.P_ID=al.P_ID
    group by
      al.Agentpart,#t.sp, #t.PayKoeff, al.AG_ID, P.Fio, #t.b_id, gr.MainParent, G2.GrpName) E
  inner join AgentList SV on SV.ag_id=E.ag_id
  inner join Deps D on D.DepID=sv.depID
where 
  sv.depid=@DepID
group by 
  e.AG_ID, e.Fio,     
  e.b_id, e.BrFam,
  e.Agentpart, e.MainParent,e.GrpName
  order by e.AG_ID, e.Fio, e.Agentpart, e.MainParent,e.GrpName
end