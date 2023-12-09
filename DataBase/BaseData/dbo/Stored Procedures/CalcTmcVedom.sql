CREATE procedure CalcTmcVedom
  @Ncodlist varchar(100), @day0 datetime, @day1 datetime
as
declare @nn0 int, @nn1 int
declare @NeedToday int;

begin
  set @nn0=dbo.InDatNom(1, @day0);
  
  if @day1<dbo.today() begin
    set @nn1=dbo.InDatNom(9999, @day1);
    set @NeedToday=0;
  end;
  else begin
    set @nn1=dbo.InDatNom(9999, DATEADD(day, -1, dbo.today()));
    set @NeedToday=1;
  end;
  
  
  -- Бывает в Izmen пустое поле Hitag. Надо побороться:
  update izmen set hitag=(select hitag from visual where Visual.id=izmen.id) 
    where izmen.act='Скла' and izmen.nd>=@day0 and izmen.hitag is NULL;
  update izmen set hitag=(select hitag from tdvi where tdvi.id=izmen.id) 
    where izmen.act='Скла' and izmen.nd=dbo.today() and izmen.hitag is NULL;
  
  
  -- Список поставщиков перепишу в отдельную таблицу:
  create table #Ve(ncod int primary key);
  insert into #ve(ncod) select distinct K from dbo.Str2intarray(@ncodlist);
  

  -- Начальный остаток:
  create table #s (sklad int, hitag int, Start int default 0);
  insert into #s(sklad,hitag,start) 
  select 
    v.sklad, v.hitag, sum(v.eveningrest) as Start 
  from 
    MorozArc..ArcVI v 
    inner join #ve on #ve.ncod=v.Ncod
  where 
    v.WorkDate=DATEADD(day, -1, @day0)
  group by sklad, hitag;
  
  -- таблица движений:
  create table #m (tip smallint, Ncod int, Fam varchar(100), sklad int, hitag int, 
  QtyIn int default 0, QtyOut int default 0, ND datetime, DocNom varchar(20));


  -- ACT=1 Все поступления:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyIn, ND, DocNom)
  select 
     1 as tip, cm.Ncod, Def.brName as Fam,
     i.sklad, i.hitag, sum(i.kol) as qtyIn, i.nd as nd,
     iif(cm.doc_nom='', cast(cm.ncom as varchar(20)), cm.doc_nom) as DocNom     
  from 
    inpdet i
    inner join Comman CM on CM.Ncom=i.Ncom
    inner join Def on Def.Ncod=cm.Ncod
    inner join #ve on #ve.ncod=CM.ncod
  where 
    i.nd between @day0 and @day1
  group by
     cm.Ncod,  Def.BrName, i.sklad, i.hitag,  iif(cm.doc_nom='', cast(cm.ncom as varchar(20)), cm.doc_nom), i.nd;


  --ACT=2 Все продажи по вчерашний день включительно:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyOut, ND, DocNom)
  select
     2 as tip, nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, sum(nv.kol) as qtyOut, nc.nd,
--     iif(nc.stfnom='', nc.stfnom, nc.datnom) as DocNom     
     nc.datnom as DocNom
  from 
    nv
    inner join nc on nc.datnom=nv.datnom
    inner join Visual V on V.ID=nv.TekId
    inner join #ve on #ve.ncod=v.ncod
  where 
    nv.datnom between @nn0 and @nn1
    and nv.kol>0
  group by
     nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, nc.nd,
     nc.datnom; --  iif(nc.stfnom='', nc.stfnom, nc.datnom);

  -- ACT=2 А если надо, то и сегодняшние:   
  if  @needToday=1
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyOut, ND, DocNom)
  select
     2 as tip, nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, sum(nv.kol) as qtyOut, nc.nd,
     nc.datnom as DocNom -- iif(nc.stfnom='', nc.stfnom, nc.datnom) as DocNom     
  from 
    nv
    inner join nc on nc.datnom=nv.datnom
    inner join tdvi V on V.ID=nv.TekId
    inner join #ve on #ve.ncod=v.ncod
  where 
    nv.datnom between dbo.InDatNom(1,dbo.today()) and dbo.InDatNom(9999, dbo.today())
    and nv.kol>0
  group by
     nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, nc.nd,
     nc.datnom; -- iif(nc.stfnom='', nc.stfnom, nc.datnom);
     
     
  -- ACT=3 Все возвраты по вчерашний день включительно:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyIn, ND, DocNom)
  select
     3 as tip, nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, sum(-nv.kol) as qtyIn, nc.nd,
     nc.datnom -- iif(nc.stfnom='', nc.stfnom, nc.datnom) as DocNom     
  from 
    nv
    inner join nc on nc.datnom=nv.datnom
    inner join Visual V on V.ID=nv.TekId
    inner join #ve on #ve.ncod=v.ncod
  where 
    nv.datnom between @nn0 and @nn1
    and nv.kol<0
  group by
     nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, nc.nd,
     nc.datnom; -- iif(nc.stfnom='', nc.stfnom, nc.datnom);

  -- ACT=3. А если надо, то и сегодняшние возвраты:   
  if  @needToday=1
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyIn, ND, DocNom)
  select
     3 as tip, nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, sum(-nv.kol) as qtyIn, nc.nd,
     nc.datnom -- iif(nc.stfnom='', nc.stfnom, nc.datnom) as DocNom     
  from 
    nv
    inner join nc on nc.datnom=nv.datnom
    inner join tdvi V on V.ID=nv.TekId
    inner join #ve on #ve.ncod=v.ncod
  where 
    nv.datnom between dbo.InDatNom(1,dbo.today()) and dbo.InDatNom(9999, dbo.today())
    and nv.kol<0
  group by
     nc.B_ID, nc.Fam,
     nv.sklad, nv.hitag, nc.nd,
     nc.datnom; -- iif(nc.stfnom='', nc.stfnom, nc.datnom);
     

  -- ACT=4. Ищу все перемещения между складами. Допустим, сначала расход:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyOut, ND, DocNom)
  select
     4 as tip, 0, 'Внутреннее перемещение со склада '+cast(iz.sklad as varchar(5)) as Fam,
     iz.sklad, iz.hitag, sum(iz.kol) as qtyOut, iz.nd, iz.SerialNom as DocNom     
  from 
    izmen iz
    inner join #ve on #ve.ncod=iz.ncod
  where 
    iz.nd between @day0 and @day1
    and iz.act='Скла'
    and iz.kol<>0 and iz.sklad<>iz.newsklad
  group by
     iz.sklad, iz.hitag, iz.nd,iz.SerialNom;
  
  -- ACT=4. То же самое, только расход:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyIn, ND, DocNom)
  select
     4 as tip, 0, 'Внутреннее перемещение на склад '+cast(iz.Newsklad as varchar(5)) as Fam,
     iz.Newsklad as Sklad, iz.hitag, sum(iz.kol) as qtyIn, iz.nd, iz.SerialNom as DocNom     
  from 
    izmen iz
    inner join #ve on #ve.ncod=iz.ncod
  where 
    iz.nd between @day0 and @day1
    and iz.act='Скла'
    and iz.kol<>0 and iz.sklad<>iz.newsklad
  group by
     iz.Newsklad, iz.hitag, iz.nd,iz.SerialNom;
     
  -- ACT=5. Коррекция остатка в обе стороны:
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyIn, qtyOut,ND, DocNom)
  select 
    5 as Tip, 0 as Ncod, 
    'Коррекция остатка по результатам сверки склада '+cast(iz.sklad as varchar(5)) as Fam, 
    iz.Sklad,iz.Hitag, 
    SUM(iif(newKol>kol, NewKol-Kol,0)) as QtyIn,
    SUM(iif(newKol<kol, -NewKol+Kol,0)) as QtyOut,
    iz.nd,  iz.SerialNom as DocNom
  from 
    izmen iz 
    inner join #ve on #ve.ncod=iz.ncod
  where 
    iz.act='испр' 
    and iz.nd between @day0 and @day1 
  group by 
    iz.Sklad,iz.Hitag, iz.nd,  iz.SerialNom;

  -- Act=6. Операция Div-, разукомплектация:   
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyOut, ND, DocNom)
  select
     6 as tip, 0, 'Разукомплектация на складе '+cast(iz.sklad as varchar(5)) as Fam,
     iz.sklad, iz.hitag, sum(iz.Kol-iz.Newkol) as qtyOut, iz.nd, iz.SerialNom as DocNom     
  from 
    izmen iz
    inner join #ve on #ve.ncod=iz.ncod
  where 
    iz.nd between @day0 and @day1
    and iz.act='div-'
    and iz.Newkol<>iz.Kol
  group by
     iz.sklad, iz.hitag, iz.nd,iz.SerialNom;
  
  -- Act=7. Операция Div+, комплектация:   
  insert into #m(tip, Ncod, Fam, sklad,hitag,qtyin, ND, DocNom)
  select
     6 as tip, 0, 'Комплектация на складе '+cast(iz.sklad as varchar(5)) as Fam,
     iz.sklad, iz.hitag, sum(iz.NewKol-iz.kol) as qtyin, iz.nd, iz.SerialNom as DocNom     
  from 
    izmen iz
    inner join #ve on #ve.ncod=iz.ncod
  where 
    iz.nd between @day0 and @day1
    and iz.act='div+'
    and iz.Newkol<>iz.Kol
  group by
     iz.sklad, iz.hitag, iz.nd,iz.SerialNom;
  

  create table #r(sklad int, hitag int, start int default 0, TotalIn int default 0, TotalOut int default 0);
  
  insert into #r(sklad,hitag)
  select distinct sklad,hitag 
  from #s 
  union 
  select distinct sklad,hitag from #m;
  
  update #r set START=isnull((select start from #s where #s.hitag=#r.hitag and #s.sklad=#r.sklad),0);
  update #r set TotalIn=ISNULL((select sum(qtyIn) from #m where #m.sklad=#r.sklad and #m.hitag=#r.hitag),0);
  update #r set TotalOut=isnull((select sum(qtyOut) from #m where #m.sklad=#r.sklad and #m.hitag=#r.hitag),0);
 
--  select * from #r;
--  select * from #m;
  
  select #r.*, #m.*, nm.name, Meas.ShortN
  from 
    #r 
    left join #m on #m.hitag=#r.hitag and #m.sklad=#r.sklad
    inner join nomen nm on nm.hitag=#r.hitag
    left join Meas on Meas.MeasId=nm.measId
  order by nm.name, #r.sklad,#m.nd, #m.tip;
  
end