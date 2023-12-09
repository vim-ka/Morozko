CREATE procedure PrepareStat @day0 datetime, @day1 datetime, 
  @day10 datetime, @day11 datetime
as
begin
  -- Заготовка:
  create table #t (ag_id int, Kol0 int, Kol1 int,
    Sku0 INT default 0, Sku1 int default 0,
    Sp0 decimal(12,2) default 0, Sp1 decimal(12,2) default 0,
    Stm0 int default 0, Stm1 int default 0,
    Back0 int  default 0, Back1 int default 0,
    New0 int default 0, New1 int default 0,
    Cls0 int default 0, Cls int default 0 );

  -- Что относится к продажам:
  insert into #t(ag_id, kol0,sku0,sp0, kol1,sku1,sp1)
  select ag_id, sum(kol0) kol0, sum(sku0) sku0,
    sum(sp0) sp0, sum(kol1) kol1,
    sum(sku1) sku1, sum(sp1) sp1
  from 
    (SELECT
      NC.Ag_Id,
      COUNT(DISTINCT nc.DATNOM) Kol0, count(distinct nv.Hitag) as SKU0, sum(nv.kol*nv.price*(1.0+nc.extra/100)) as SP0,
      0 as Kol1, 0 as SKU1,  0 as SP1
    FROM 
      NV inner join NC on NC.datnom=nv.datnom
      INNER JOIN AGENTS A ON A.AG_ID=NC.Ag_Id
    WHERE 
      Nc.ND BETWEEN @day0 AND @day1
      and nc.tara=0 and nc.frizer=0 and nc.Actn=0 and nc.Srok>0 and nc.ag_id>0
    group by 
      NC.Ag_Id
      
    union

    SELECT
      NC.Ag_Id,
      0 as Kol0, 0 as SKU0,  0 as SP0,
      COUNT(DISTINCT nc.DATNOM) Kol1, count(distinct nv.Hitag) as SKU1, sum(nv.kol*nv.price*(1.0+nc.extra/100)) as SP1
    FROM 
      NV inner join NC on NC.datnom=nv.datnom
      INNER JOIN AGENTS A ON A.AG_ID=NC.Ag_Id
    WHERE 
      Nc.ND BETWEEN @day10 AND @day11
      and nc.tara=0 and nc.frizer=0 and nc.Actn=0 and nc.srok>0 and nc.ag_id>0
    group by 
      NC.Ag_Id
    ) E
  group by ag_id;
  
  
  -- Подготовка к расчету продаж собственных торговых марок:
/*  create table #m (ag_id int, N int);
  insert into #m
    select nc.ag_id, count(distinct n.hitag)
    from nv inner join nc on nc.datnom=nv.datnom
      inner join Nomen n on n.hitag=nv.hitag and n.STM=1
    where NC.nd between @day0 and @day1
      and nc.tara=0 and nc.frizer=0 and nc.Actn=0
    group by nc.ag_id;
  update #t set stm0=(select N from #m where #m.ag_id=#t.ag_id);

  truncate table #m;
  insert into #m
    select nc.ag_id, count(distinct n.hitag)
    from nv inner join nc on nc.datnom=nv.datnom
      inner join Nomen n on n.hitag=nv.hitag and n.STM=1
    where NC.nd between @day10 and @day11
      and nc.tara=0 and nc.frizer=0 and nc.Actn=0
    group by nc.ag_id;
  update #t set stm1=(select N from #m where #m.ag_id=#t.ag_id);
*/    
  
  select 
    s.DepID, D.DName,
    a.SV_ID, s.Fam as SuperFam,
    #t.AG_ID, a.Fam as AgentFam,
    #t.kol0, #t.kol1,
    #t.sku0, #t.sku1,
    #t.sp0, #t.sp1
  from 
    #t inner join Agents A on A.AG_ID=#t.ag_id
    inner join supervis s on s.SV_ID=a.SV_ID
    inner join Deps D on D.DepID=s.DepID
  where s.DepID>0 and a.sv_id>0 and #t.ag_id>0
  order by s.DepID, a.SV_ID, #t.AG_ID
end