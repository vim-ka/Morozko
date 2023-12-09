CREATE procedure Guard.CatReport @day0 datetime='01.01.2015', @day1 datetime='31.05.2018', @SlowMode bit=0
-- Отчет для Кати и фин.директора, списания на 7500 подробно:
as
declare @dtn0 int, @dtn1 int
begin
print 'point 1'
  set @dtn0=dbo.fnDatnom(@day0-122, 1) -- интервал номеров анализируемых возвратов
  set @dtn1=dbo.fnDatnom(@day1, 9999) -- последние два месяца до даты возврата
  
  if Object_ID('Guard.CatRep') is not null drop table Guard.CatRep;
  create table Guard.CatRep(crid int not null identity primary key,
    ND datetime, RemvDatnom int,  Actn bit, ourid smallint, b_id int, buyer varchar(100), id int, startid int, hitag int, 
    Kol decimal(10,3),
    Cost decimal(12,4), Price decimal(12,4), DateR datetime, Srokh datetime,
    n_Vet_svid varchar(50), Ncom int,
    BackDatnom int, BackStfnom varchar(30), BackStfDate datetime,
    SellDatnom int, SellStfNom varchar(30), SellStfDate datetime,
    Sert_ID int,
    flgWeight bit, Weight decimal(10,3), Netto decimal(10,3), 
    EffDate datetime, Cost1kg decimal(10,3) default 0,  MRK bit default 0,
    tid int default 0
    );
  
  insert into Guard.CatRep(b_id, Nd, RemvDatnom, Actn, id, startid, hitag, flgWeight, weight, netto, 
    Kol, cost, price, dater, srokh, ncom, sert_id, EffDate)
  select
    nc.b_id, nc.nd, nc.datnom, nc.actn, nv.tekid, v.startid, nv.hitag, nm.flgWeight, v.weight, nm.netto, 
    nv.kol, nv.cost, nv.price, v.dater, v.srokh, v.ncom, v.sert_id, nc.nd
  from
    nc 
    inner join nv on nv.datnom=nc.datnom
    inner join nomen nm on nm.hitag=nv.hitag
    inner join visual v on v.id=nv.tekid
  inner join Defcontract DC on DC.dck=nc.dck
  where 
    nc.nd between @day0 and @day1 and (nc.b_id=7500 or dc.degust>0  or nc.actn=1) -- добавлено 20.06.2018
    and nv.Kol>0
    and nc.STip<>4
  order by nc.datnom
  
print 'point 2'

  -- update Guard.CatRep set Effdate=DateAdd(YEAR, Nd,1) where nd between '01.01.2016' AND '30.09.2016'

  update Guard.CatRep set flgWeight=1 where flgWeight=0 and Weight>0;
  update Guard.CatRep set flgWeight=0 where flgWeight=1 and Weight=0 and netto=0;
  update Guard.CatRep set weight=netto where weight=0 and netto<>0 and flgweight=1;
  update Guard.CatRep set Kol=Kol*weight, Price=Price/Weight, Cost=Cost/Weight where flgWeight=1 and weight<>0;
  update Guard.CatRep set dater=v.dater from Guard.CatRep inner join visual v on v.id=Guard.CatRep.startid where Guard.CatRep.dater is null and v.dater is not null;
  update Guard.CatRep set srokh=v.srokh from Guard.CatRep inner join visual v on v.id=Guard.CatRep.startid where Guard.CatRep.srokh is null and v.srokh is not null;
  
  -- Проставляю фиктивные даты и сроки, где их нет вообще:
  update Guard.CatRep set DateR=Guard.CatRep.EffDate-25-round(15*rand(),0) where DateR is null;
  update Guard.CatRep set Srokh=DateR+nm.ShelfLife
    from Guard.CatRep inner join Nomen nm on nm.hitag=Guard.CatRep.Hitag
    where Guard.CatRep.srokh is NULL
  
  -- А кто же этот товар нам вернул?
  update Guard.CatRep set backdatnom=(select max(datnom) from nv where nv.tekid=Guard.CatRep.id and nv.datnom<dbo.fnDatnom(Guard.CatRep.effdate,1) and nv.kol<0);
print 'point 3'
  
  if @SlowMode=1 begin
      -- Если не удается найти именно эту партию товара, беру просто с совпадающим названием, лишь бы возврат раньше списания:
      -- Вот так ОЧЕНЬ долго: update Guard.CatRep set backdatnom=(select max(datnom) from nv where nv.hitag=Guard.CatRep.hitag and nv.datnom<Guard.CatRep.remvdatnom and nv.kol<0) where backdatnom is null;
    if Object_ID('tempdb..#b') is not null drop table #b;

    create table #b(hitag int, datnom int);

    insert into #b(hitag, datnom) select distinct hitag, datnom from nv where kol<0 and datnom>=@dtn0 and datnom<=@dtn1;
    create index b_tmp_idxh on #b(hitag);
    create index b_tmp_idxd on #b(datnom);
print 'point 4'
    
    update Guard.CatRep set backdatnom=(select max(datnom) from #b where #b.hitag=Guard.CatRep.hitag 
        and #b.datnom < dbo.fnDatnom(Guard.CatRep.effdate,1)
        and dbo.DatNomInDate(#b.datnom)>=Guard.CatRep.EffDate-122) -- глубина поиска 4 месяца
    where backdatnom is null;
  end;
print 'point 5'


  update Guard.CatRep set mrk=1 where B_ID=7500;

  update Guard.CatRep set BackStfnom=nc.stfnom from Guard.CatRep inner join nc on nc.datnom=Guard.CatRep.backdatnom;
  update Guard.CatRep set BackStfNom=backdatnom where backstfnom is null;
  update Guard.CatRep set BackStfDate=dbo.DatNomInDate(backDatnom) where BackDatnom is not null;
  update Guard.CatRep set Selldatnom=nc.refdatnom from Guard.CatRep inner join nc on nc.datnom=Guard.CatRep.BackDatnom;
  
  update Guard.CatRep set SellStfNom=nc.StfNom, B_ID=nc.b_id, ourid=nc.OurID from Guard.CatRep inner join nc on nc.datnom=Guard.CatRep.Selldatnom;
  update Guard.CatRep set SellStfNom=Selldatnom where SellStfNom is null and Selldatnom is not null;
  update Guard.CatRep set SellStfDate=dbo.DatNomInDate(Selldatnom) where Selldatnom is not null;
  
  update Guard.CatRep set buyer=def.gpname from Guard.CatRep inner join def on def.pin=Guard.CatRep.b_id where b_id is not null;
  update Guard.CatRep set b_id=ourid where ourid is not null and ourid<>7;
  update Guard.CatRep set buyer=f.OurName from Guard.CatRep inner join firmsconfig f on f.Our_id=Guard.CatRep.b_id;
print 'point 6'
  

  update Guard.CatRep set Cost1kg=Cost/Netto where Netto<>0;


  update Guard.CatRep
    set n_Vet_svid = S.N_vet_svid
  from
    Guard.CatRep
    inner join comman cm on cm.ncom=Guard.CatRep.Ncom
    inner join InpdetVetSvid IV on IV.id=Guard.CatRep.startid and IV.OurID=cm.our_id
    inner join SertifVetSvid S on S.Our_id=cm.our_id and S.Id_vet_svid=IV.VetId and s.Is_Del=0;
  
  --  if @AddYear<>0 begin
  --    update Guard.CatRep set DateR=DateAdd(year,@AddYear,DateR) where DateR is not null;
  --    update Guard.CatRep set srokh=DateAdd(year,@AddYear,srokh) where srokh is not null;
  --    update Guard.CatRep set BackStfDate=DateAdd(year,@AddYear,BackStfDate) where BackStfDate is not null;
  --    update Guard.CatRep set SellStfDate=DateAdd(year,@AddYear,SellStfDate) where SellStfDate is not null;
  --  end;
print 'point 6'
  
  select
    nm.name, iif(Guard.CatRep.flgWeight=0,'шт','кг') Unit,
    Guard.CatRep.*, Guard.CatRep.Price*Guard.CatRep.Kol as BackSumPrice, cm.doc_nom as InpDocNom, cm.ncod,
    cm.doc_date as InpDocDate, ve.fam as Vendor
  from
    Guard.CatRep
    inner join nomen nm on nm.hitag=Guard.CatRep.hitag
    left join comman cm on cm.ncom=Guard.CatRep.ncom
    left join vendors ve on ve.ncod=cm.ncod
  -- ОСНОВНОЙ РАСЧЕТ ЗАКОНЧЕН
 
print 'point 7'
  
  /**********************************************
  **   РАЗБИВКА ПО ПЕРИОДАМ ВЫВОЗА НА СВАЛКУ   **
  **********************************************/
  if Object_ID('tempdb.#s') is not null drop table #s;
  create table #s(day1 datetime);
  insert into #s values('18.01.2016');
  insert into #s values('18.01.2016');
  insert into #s values('04.02.2016');
  insert into #s values('04.02.2016');
  insert into #s values('18.02.2016');
  insert into #s values('18.02.2016');
  insert into #s values('18.02.2016');
  insert into #s values('02.03.2016');
  insert into #s values('02.03.2016');
  insert into #s values('28.03.2016');
  insert into #s values('28.03.2016');
  insert into #s values('30.03.2016');
  insert into #s values('30.03.2016');
  insert into #s values('08.06.2016');
  insert into #s values('08.06.2016');
  insert into #s values('11.06.2016');
  insert into #s values('11.06.2016');
  insert into #s values('25.03.2017');
  insert into #s values('25.03.2017');
  insert into #s values('25.03.2017');
  insert into #s values('25.03.2017');
  insert into #s values('27.03.2017');
  insert into #s values('27.03.2017');
  insert into #s values('27.03.2017');
  insert into #s values('27.03.2017');
  insert into #s values('03.05.2017');
  insert into #s values('03.05.2017');
  insert into #s values('03.05.2017');
  insert into #s values('03.05.2017');
  insert into #s values('05.05.2017');
  insert into #s values('05.05.2017');
  insert into #s values('06.05.2017');
  insert into #s values('06.05.2017');
  insert into #s values('11.05.2017');
  insert into #s values('11.05.2017');
  insert into #s values('11.05.2017');
  insert into #s values('11.05.2017');
  insert into #s values('19.05.2017');
  insert into #s values('19.05.2017');
  insert into #s values('20.05.2017');
  insert into #s values('20.05.2017');
  insert into #s values('24.05.2017');
  insert into #s values('26.05.2017');
  insert into #s values('26.05.2017');
  insert into #s values('27.05.2017');
  insert into #s values('27.05.2017');
  insert into #s values('29.05.2017');
  insert into #s values('29.05.2017');
  insert into #s values('06.06.2017');
  insert into #s values('06.06.2017');
  insert into #s values('09.06.2017');
  insert into #s values('09.06.2017');
  insert into #s values('10.06.2017');
  insert into #s values('10.06.2017');
  insert into #s values('10.06.2017');
  insert into #s values('13.06.2017');
  insert into #s values('13.06.2017');
  insert into #s values('23.06.2017');
  insert into #s values('23.06.2017');
  insert into #s values('29.06.2017');
  insert into #s values('29.06.2017');
  insert into #s values('01.07.2017');
  insert into #s values('01.07.2017');
  insert into #s values('02.07.2017');
  insert into #s values('02.07.2017');
  insert into #s values('18.07.2017');
  insert into #s values('17.08.2017');
  insert into #s values('17.08.2017');
  insert into #s values('19.09.2017');
  insert into #s values('19.09.2017');
  insert into #s values('28.09.2017');
  insert into #s values('28.09.2017');
  insert into #s values('19.10.2017');
  insert into #s values('19.10.2017');
  insert into #s values('15.11.2017');
  insert into #s values('15.11.2017');
  insert into #s values('28.11.2017');
  insert into #s values('28.11.2017');
  insert into #s values('28.11.2017');
  insert into #s values('28.11.2017');
  insert into #s values('14.12.2017');
  insert into #s values('14.12.2017');
  insert into #s values('28.12.2017');
  insert into #s values('28.12.2017');
  insert into #s values('26.01.2018');
  insert into #s values('26.01.2018');
  insert into #s values('09.02.2018');
  insert into #s values('09.02.2018');
  insert into #s values('09.02.2018');
  insert into #s values('09.02.2018');
  insert into #s values('20.02.2018');
  insert into #s values('20.02.2018');
  insert into #s values('12.04.2018');
  insert into #s values('12.04.2018');
  insert into #s values('10.05.2018');
  insert into #s values('17.05.2018');
print 'point 8'
  
  if Object_ID('Guard.CatPeriod') is not null drop table Guard.CatPeriod;
  create table Guard.CatPeriod(id int not null identity primary key, Day0 datetime, Day1 datetime);
  insert into Guard.CatPeriod(day1) select distinct day1 from #s order by day1;
  -- select * from Guard.CatPeriod
  update Guard.CatPeriod set day0=(select max(p2.day1)+1 from Guard.CatPeriod p2 where p2.day1<Guard.CatPeriod.day1)
  update Guard.CatPeriod set day0='01.01.2016' where id=1;
  
  --  select  digit, cast(sum(tonn) as decimal(8,3)), sum(TRub) TRyb from (
  --  select Guard.CatRep.RemvDatnom % 10 as Digit, p.id, p.day0, p.day1, cast(sum(iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as Tonn,
  --    cast(sum(Guard.CatRep.kol*Guard.CatRep.price*0.001) as decimal(10,2)) as TRub
  --  from Guard.CatPeriod p inner join Guard.CatRep on Guard.CatRep.nd between p.day0 and p.Day1
  --    -- and Guard.CatRep.nd>='01.01.2017'
  --    and actn=1
  --    group by Guard.CatRep.remvdatnom % 10, p.id, p.day0, p.day1
  --  ) E
  --  group by E.Digit


  select  
    'До 31.05.2016' as Period,
    cast(sum(iif(b_id=7500,1,0)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRub7500,
    cast(sum(iif(b_id=7500,1,0)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as Tonn7500,
    cast(sum(iif(b_id=7500,0,1)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubOther,
    cast(sum(iif(b_id=7500,0,1)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnOther,
    cast(sum(Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubTotal,
    cast(sum(iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnTotal
  from  Guard.CatRep 
  where effdate <= '31.05.2016'
  UNION
  select  
    '01.06.2016 - 28.02.2018' as Period,
    cast(sum(iif(b_id=7500,1,0)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRub7500,
    cast(sum(iif(b_id=7500,1,0)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as Tonn7500,
    cast(sum(iif(b_id=7500,0,1)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubOther,
    cast(sum(iif(b_id=7500,0,1)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnOther,
    cast(sum(Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubTotal,
    cast(sum(iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnTotal
  from  Guard.CatRep 
  where effdate between '01.06.2016' and '28.02.2018'
  UNION
  select  
    '01.03.2018 - 30.06.2018' as Period,
    cast(sum(iif(b_id=7500,1,0)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRub7500,
    cast(sum(iif(b_id=7500,1,0)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as Tonn7500,
    cast(sum(iif(b_id=7500,0,1)*Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubOther,
    cast(sum(iif(b_id=7500,0,1)*iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnOther,
    cast(sum(Guard.CatRep.kol*Guard.CatRep.cost*0.001) as decimal(10,2)) as TRubTotal,
    cast(sum(iif(flgweight=1,kol,kol*netto))/1000 as decimal(10,3)) as TonnTotal
  from  Guard.CatRep 
  where effdate between '01.03.2018' and '30.06.2018'


end;