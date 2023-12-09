CREATE procedure Guard.DevRep3 @Comp varchar(30), @day0 datetime, @day1 DATETIME
-- Результат расчета будет записан в табл. Guard.DevRep3rez
AS
declare @nd datetime
BEGIN
  -- список развивающих:
  create table #dev (devId int); 
  insert into #dev (devId) 
  select distinct a.ag_id as DevID
    from agentlist a inner join Person P on P.p_id=a.p_id
    where a.depid=47;
  create index dev_tmp_idx on #dev(devId);
  
-- Это для отладки:
-- SELECT * from #dev order by devid;

  -- Теперь к каждому развивающему агенту нужно привязать тех обычных агентов, к которым они были привязаны в заданном периоде с указанием даты привязки. 
  -- Создам заготовку, список дат в указанном интервале:

  create table #DT(nd datetime);
  set @nd = @day0;
  while @nd<=dateadd(HOUR,1,@day1) BEGIN
    insert into #dt values(@nd);
    set @nd=@nd+1;
  end;
  create index dt_tmp_idx on #dt(nd);

-- Это для отладки:
-- select * from #DT;

  -- Создам таблицу ежедневной привязки и навтыкаю данные из Guard.Chain:
  create table #CHN(nd datetime, devId int, ag_Id int);
  insert into #chn(nd,devId,ag_ID)
  select DISTINCT
    #dt.nd, c.ChainAg_Id, c.SourAG_ID
  from 
    #DT 
    inner join Guard.Chain c on C.day0<=#dt.nd and c.Day1>=#dt.nd;

-- Это для отладки:
-- select * from #chn;

  -- Оч.хорошо! Теперь следует выдрать все продажи по найденным агентам и дням, кроме сегодня:
  create table #SE(ND datetime, devID int, ag_id int, B_ID int, Ncod int, Hitag int, 
    Sell int, SellSC decimal(10,2),  SellSP decimal(10,2),  SellKG decimal(10,3), STip smallint);
  insert into #SE
  SELECT 
    c.nd, c.devId, c.ag_Id, nc.B_ID, abs(V.Ncod) Ncod, nv.Hitag,
    sum(nv.kol) as Sell,
    sum(nv.kol*nv.cost) as SellSC,
    sum(nv.kol*nv.price*(1.0+nc.extra/100)) as SellSP,
    sum(nv.kol*iif(v.weight>0, v.Weight, nm.Netto)) as SellKG, nc.stip
  FROM
    #CHN C
    inner join nc on nc.nd=c.nd and nc.ag_id=C.ag_Id
    inner join nv on nv.datnom=nc.DatNom
    inner join Visual V on v.id=nv.TekID
    inner join Nomen nm on nm.hitag=nv.Hitag
  where c.nd<dbo.today() and nv.kol>0
  group by 
    c.nd, c.devId, c.ag_Id, nc.B_ID,  abs(V.Ncod), nv.Hitag, nc.stip
  -- having sum(nv.kol*nv.price*(1.0+nc.extra/100))<>0;

  if @Day1>=dbo.today() -- отдельно за сегодня: 
    insert into #SE
    SELECT 
      c.nd, c.devId, c.ag_Id, nc.B_ID, abs(V.Ncod) Ncod, nv.Hitag,
      sum(nv.kol) as Sell,
      sum(nv.kol*nv.cost) as SellSC,
      sum(nv.kol*nv.price*(1.0+nc.extra/100)) as SellSP,
      sum(nv.kol*iif(v.weight>0, v.Weight, nm.Netto)) as SellKG, nc.stip
    FROM
      #CHN C
      inner join nc on nc.nd=c.nd and nc.ag_id=C.ag_Id
      inner join nv on nv.datnom=nc.DatNom
      inner join tdvi V on v.id=nv.TekID
      inner join Nomen nm on nm.hitag=nv.Hitag
    where c.nd=dbo.today() and nv.kol>0
    group by 
      c.nd, c.devId, c.ag_Id, nc.B_ID,  abs(V.Ncod), nv.Hitag, nc.stip





  delete from Guard.DevRep3rez where Comp=@comp;

  insert into Guard.DevRep3rez(Comp,ND,devID,ag_id,B_ID,Hitag,Sell,SellSC,SellSP,SellKG,Ncod,STip)
  select @Comp,ND,devID,ag_id,B_ID,Hitag,Sell,SellSC,SellSP,SellKG,Ncod,Stip from #SE;

  drop table #SE;
  drop table #dev;
  drop table #dt;

-- Это для отладки:
select cast(0 as bit) as Mrk, r.Ncod, def.brname as Vendor,  
  r.Hitag, nm.Name, sum(r.SellSP) SellSP, sum(r.SellKG) SellKG, sum(iif(r.stip=3,1,0)*r.Sell) as ActnKol
from 
  Guard.DevRep3rez r
  inner join Nomen nm on nm.hitag=r.Hitag
  inner join def on def.ncod=r.ncod
where Comp = @Comp
group by r.Hitag, nm.Name, r.ncod, def.brname
order by r.ncod, nm.name;


END