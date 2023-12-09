--расчет статистики для акций по агентам
CREATE procedure dbo.MarketRequestCalcByAgents_copy @MRID int, @nd0 datetime, @nd1 datetime, @flgDebug bit=0, @skipproclist bit=1 
WITH RECOMPILE
as
declare @datnom0 int, @datnom1 int,@tek datetime,@slotid int,@tip int, 
  @once bit,@anysku bit,@cnt int,@dayA datetime,@dayB datetime, @PlanVal decimal(12,3),
  @MinSkuKol int
begin

select * from MarketRequestPrepared where mrid=462;

  delete from MarketRequestRes where mrid=@MRID;
  set @MinSkuKol=(select max(MinSkuKol) from MarketRequestSlotMeh where mrid=@mrid);

-- если @skipproclist = 1, то пропускать обработанные накладные в таблице SourceNaklProcList
  set nocount on
--  dbcc FREEPROCCACHE;
--  SET ARITHABORT ON;


  
--print('КОНТРОЛЬНАЯ ТОЧКА 1 ПРОЙДЕНА')
  select @dayA = datefrom, @dayB = dateto from MarketRequest where id = @mrid 
--print('КОНТРОЛЬНАЯ ТОЧКА 2 ПРОЙДЕНА')
  if @dayA > @nd0	set @nd0 = @dayA
  if @dayB < @nd1	set @nd1 = @dayB    
  set @datnom0 = dbo.InDatNom(1, @nd0);
  set @datnom1 = dbo.InDatNom(9999, @nd1);


  if object_id('tempdb..#UsedNak') is not null drop table #UsedNak;
  create table #UsedNak(datnom int);

  if object_id('tempdb..#nkk') is not null drop table #nkk;
  create table #nkk(datnom int, ag_id int, b_id int, hitag int, kol int, sp numeric(10, 2), wgt numeric(10,3), Box int, DepID int, Tip smallint)

--print('КОНТРОЛЬНАЯ ТОЧКА 3 ПРОЙДЕНА')

  if @nd0=dbo.today() and @nd1=dbo.today() begin
    insert into #nkk(datnom, ag_id, b_id, hitag, kol, sp, wgt)
    select r1.datnom, r1.ag_id, r1.b_id, r1.hitag, sum(r1.kol) sum_kol, sum(r1.pr) sum_pr, sum(r1.wgt) sum_wgt from (select
      nc.datnom, nc.ag_id, nc.b_id, nv.hitag, nv.kol, nv.Price * nv.kol * (1 + 0.01 * nc.Extra) pr, IIF(v.weight = 0, n.Netto, v.weight) * nv.kol wgt
    from
      nc
      inner join nv on nv.datnom = nc.datnom
      -- так было: inner join (SELECT pin from dbo.MarketRequestPlan where mrid = @mrid GROUP BY pin) mrp on mrp.pin = nc.b_id
      inner join MarketRequestPrepared P on p.b_id=nc.b_id and p.mrid=@MRID
      inner join MarketRequestTovs t on t.hitag = NV.Hitag
      inner join tdvi v on v.id = nv.TekID
      inner join nomen n on n.hitag = nv.hitag
      inner join defcontract dc on dc.dck=nc.dck
      inner join agentlist A on A.ag_id=dc.ag_id
      inner join MarketRequestDeps Deps on Deps.depid=a.depid and deps.mrid=t.mrid
    where
      nc.datnom >= @datnom0 and nc.datnom <= @datnom1
      and nc.Tomorrow = 0
      and nc.actn = 0
      and nc.frizer = 0
      and t.bonus = 0
      and nv.kol > 0
      and t.mrid = @mrid
      and nc.RefDatnom=0
      and (nc.remark like '%Акц%' or nc.remark like '%Бонус%')
    union all
    select
      nvz.datnom, nc.ag_id, nc.b_id, nvz.hitag, nvz.Zakaz, nvz.Price * n.Netto * nvz.Zakaz * (1 + 0.01 * nc.Extra), n.Netto * nvz.Zakaz 
    from
      nvzakaz nvz
      inner join nc on nc.datnom = nvz.datnom
--      inner join (SELECT pin from dbo.MarketRequestPlan where mrid = @mrid GROUP BY pin) mrp on mrp.pin = nc.b_id
      inner join MarketRequestPrepared P on p.b_id=nc.b_id and p.mrid=@MRID
      inner join MarketRequestTovs t on t.hitag = nvz.Hitag
      inner join nomen n on n.hitag = nvz.hitag  
      inner join defcontract dc on dc.dck=nc.dck
      inner join agentlist A on A.ag_id=dc.ag_id
      inner join MarketRequestDeps Deps on Deps.depid=a.depid and deps.mrid=t.mrid
    where
      nvz.datnom >= @datnom0 and nvz.datnom <= @datnom1
      and nc.actn = 0
      and nc.frizer = 0      
      and nvz.done = 0
      and nc.RefDatnom=0
      and (nc.remark like '%Акц%' or nc.remark like '%Бонус%')
      and t.mrid = @mrid) r1
    group by r1.datnom, r1.ag_id, r1.b_id, r1.hitag
--print('КОНТРОЛЬНАЯ ТОЧКА 4 ПРОЙДЕНА')
  end
  else
    insert into #nkk(datnom, ag_id, b_id, hitag, kol, sp, wgt)
    select r2.datnom, r2.ag_id, r2.b_id, r2.hitag, sum(r2.kol) sum_kol, sum(r2.pr) sum_pr, sum(r2.wgt) sum_wgt from (select
      nc.datnom, nc.ag_id, nc.b_id, nv.hitag, nv.kol, nv.Price * nv.kol * (1 + 0.01 * nc.Extra) pr, IIF(v.weight = 0, n.Netto, v.weight) * nv.kol wgt
    from
      nc
      inner join nv on nv.datnom = nc.datnom
--      inner join (SELECT pin from dbo.MarketRequestPlan where mrid = @mrid GROUP BY pin) mrp on mrp.pin = nc.b_id
      inner join MarketRequestPrepared P on p.b_id=nc.b_id and p.mrid=@MRID
      inner join MarketRequestTovs t on t.hitag = NV.Hitag
      inner join Visual v on v.id = nv.TekID
      inner join nomen n on n.hitag = nv.hitag
      inner join defcontract dc on dc.dck=nc.dck
      inner join agentlist A on A.ag_id=dc.ag_id
      inner join MarketRequestDeps Deps on Deps.depid=a.depid and deps.mrid = t.mrid
    where
      nc.datnom >= @datnom0 and nc.datnom <= @datnom1
      and nc.actn = 0
      and nc.frizer = 0
      and t.bonus = 0
      and nv.kol > 0
      and t.mrid = @mrid
    union all
    select
      nvz.datnom, nc.ag_id, nc.b_id, nvz.hitag, nvz.Zakaz, nvz.Price * n.Netto * nvz.Zakaz * (1 + 0.01 * nc.Extra), n.Netto * nvz.Zakaz 
    from
      nvzakaz nvz
      inner join nc on nc.datnom = nvz.datnom
--      inner join (SELECT pin from dbo.MarketRequestPlan where mrid = @mrid GROUP BY pin) mrp on mrp.pin = nc.b_id
      inner join MarketRequestPrepared P on p.b_id=nc.b_id and p.mrid=@MRID
      inner join MarketRequestTovs t on t.hitag = nvz.Hitag
      inner join nomen n on n.hitag = nvz.hitag
      inner join defcontract dc on dc.dck=nc.dck
      inner join agentlist A on A.ag_id=dc.ag_id
      inner join MarketRequestDeps dd on dd.depid=a.depid and dd.mrid = t.mrid  
    where
      nvz.datnom >= @datnom0 and nvz.datnom <= @datnom1
      and nc.actn = 0
      and nc.frizer = 0      
      and nvz.done = 0
      and (nc.remark like '%Акц%' or nc.remark like '%Бонус%')
      and t.mrid = @mrid) r2
    group by r2.datnom, r2.ag_id, r2.b_id, r2.hitag
--print('КОНТРОЛЬНАЯ ТОЧКА 5 ПРОЙДЕНА')

  update #Nkk set Box=nm.minp*nm.mpu from #nkk inner join Nomen Nm on Nm.hitag=#nkk.hitag;
  update #Nkk set DepID=A.DepID from #nkk inner join Agentlist A on A.ag_id=#nkk.ag_id;
  update #nkk set tip=(select tip from MarketRequestSlotMeh where mrid=@MRID and bonus = 0);
  
  declare @N int; 
  set @N=(select count(*) from #NKK);
  -- select * from #Nkk order by ag_id,b_id,hitag;
  -- print('До проверки на MinSkuKol в табл. #NKK было '+cast(@N as varchar)+' записей.');
  if @MinSkuKol>0 
    delete #nkk from #NKK inner join (
      select ag_id, b_id, count(distinct Hitag) cnth from #NKK group by ag_id,b_id
      having count(distinct Hitag) < @MinSkuKol
    ) E on E.ag_id=#NKK.ag_id and E.b_id=#NKK.b_id
  -- select * from #Nkk order by ag_id,b_id,hitag;

  --  print('КОНТРОЛЬНАЯ ТОЧКА 6 ПРОЙДЕНА')
  set @PlanVal=(select top 1 Planval from MarketRequestSlotMeh where mrid=@MRID and bonus = 0 order by id desc);
  create index nkk_idx on #nkk(datnom, ag_id, b_id, hitag);

  select 'результат' as Remark,
    #nkk.depid, #nkk.ag_id, #nkk.b_id,
    sum(case 
      when #nkk.tip=0 then #nkk.kol
      when #nkk.tip=1 then #nkk.kol/#nkk.Box
      when #nkk.tip=2 then #nkk.sp
      else #nkk.wgt end)/ @PlanVal as Cnt
  from 
    #nkk
    inner join MarketRequestDeps D on D.depid=#nkk.depid    
    inner join MarketRequestTovs T on T.hitag=#nkk.hitag
  where 
    T.bonus=0
    and T.mrid=@mrid 
    and d.mrid=@MRID
  group by     
    #nkk.depid, #nkk.ag_id, #nkk.b_id
  having sum(case 
      when #nkk.tip=0 then #nkk.kol
      when #nkk.tip=1 then #nkk.kol/#nkk.Box
      when #nkk.tip=2 then #nkk.sp
      else #nkk.wgt end)/ @PlanVal >=1.00
--print('КОНТРОЛЬНАЯ ТОЧКА 7 ПРОЙДЕНА')

  insert into MarketRequestRes(mrid, ag_id, b_id, cnt)
  select 
    --  AG_ID, b_id, hitag, kol, planval, round(kol / planval - 0.4999, 0) cnt, tip
    
    @mrid,#nkk.ag_id, #nkk.b_id,
    cast(sum(case 
      when #nkk.tip=0 then #nkk.kol
      when #nkk.tip=1 then #nkk.kol/#nkk.Box
      when #nkk.tip=2 then #nkk.sp
      else #nkk.wgt end)/ @PlanVal as int) as Cnt -- округление вниз
  from 
    #nkk
    inner join MarketRequestDeps D on D.depid=#nkk.depid    
    inner join MarketRequestTovs T on T.hitag=#nkk.hitag
  where 
    T.bonus=0
    and T.mrid=@mrid 
    and d.mrid=@MRID
  group by     
    #nkk.depid, #nkk.ag_id, #nkk.b_id
  having sum(case 
      when #nkk.tip=0 then #nkk.kol
      when #nkk.tip=1 then #nkk.kol/#nkk.Box
      when #nkk.tip=2 then #nkk.sp
      else #nkk.wgt end)/ @PlanVal >=1.00;
  set nocount off
  --SET ARITHABORT OFF;  
END