CREATE procedure dbo.PrepareMarkReq_copy
as
declare @dn1 int, @dn2 int, @nd1 datetime,@nd2 datetime, @mrid int
begin
  set @ND1 = DATEADD(month, -2, dbo.today())
  set @ND2 = dbo.today()
  SET @dn1 = dbo.InDatNom(0001, @nd1)
  SET @dn2 = dbo.InDatNom(9999, @nd2)
  
  if object_id('tempdb..#tv') is not null drop table #tv
  create table #tv(mrid int,b_id int);

  create table #B(pin int);
  insert into #B 
  select dc.pin 
    from defcontract DC inner join Def on Def.pin=dc.Pin 
    where def.actual=1 and def.brName is not null and def.brAddr is not null 
    and def.Fmt not in (17, 20, 23, 25, 31)
    group by dc.pin having sum(cast(dc.debit as int))=0;
  create index b_temp_idx on #b(pin);


  insert into #tv(mrid,b_id)
  select distinct t.mrid, nc.b_id
  from  
    NC 
    inner join #B on #B.pin=nc.b_id
    inner join NV on NC.Datnom=NV.Datnom
    inner join dbo.MarketRequestTovs T on T.Hitag=nv.hitag
    inner join dbo.nomen n on n.hitag = T.hitag
    inner join dbo.nomen n2 on n2.hitag = nv.hitag and n2.ngrp=n.ngrp
    inner join MarketRequest R on R.ID =T.mrid
  where 
    nc.datnom>=1709010001
    and T.Bonus=0
    and R.datefrom<=dbo.today() and r.dateto>=dbo.today()
    and nc.Remark like '%Акц%';
  
  truncate table dbo.MarketRequestPrepared;
  insert into dbo.MarketRequestPrepared(mrid,b_id) select mrid,b_id from #tv;

  -- select mrid, count(b_id) from #tv group by mrid;

  /*
  if object_id('tempdb..#mr') is not null drop table #mr
  create table #mr(b_id int, ag_id int, cnt int)

  insert into #mr
  select  b_id,  dc.ag_id,  count(*)
  from 
    dbo.nc
    inner join dbo.nv on nv.datnom = nc.datnom
    inner join dbo.DefContract dc on dc.DCK = nc.DCK
    inner join dbo.AgentList al on al.AG_ID = dc.ag_id
    inner join dbo.nomen n on n.hitag = nv.Hitag
    inner join #tv on #tv.ngrp = n.ngrp
      and nc.datnom >= @dn1 and nc.datnom <= @dn2
      and dc.Debit = 0
      and 1 = 1
  group by nc.b_id, dc.ag_id
  
  --select * from #mr
  insert PreparedMarkReq(mrid int, ag_id int, b_id int);
  
  select al.AG_ID, d.pin
  from 
    dbo.Def d
    inner join #mr on #mr.b_id = d.pin
    inner join dbo.AgentList al on al.AG_ID = #mr.ag_id
    inner join dbo.person pa on pa.p_id = al.P_ID
    inner join dbo.AgentList als on als.AG_ID = al.sv_ag_id
    inner join dbo.person ps on ps.P_ID = als.p_id
    left join dbo.MarketRequestPlan mrp on mrp.pin = #mr.b_id and mrp.mrid = @mrid
  where 
    d.actual = 1 and d.brName is not null and d.brAddr is not null 
    and d.Fmt not in (17, 20, 23, 25, 31)
    and d.worker = 0
  group by al.AG_ID, d.pin
  order by al.AG_ID, d.pin
  */
END