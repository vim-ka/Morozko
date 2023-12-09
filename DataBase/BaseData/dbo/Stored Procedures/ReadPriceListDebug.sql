CREATE procedure dbo.ReadPriceListDebug @PLID smallint, @FirmGroup smallint=7
  -- PLID-место: 1-Воронеж, 2-Крым
  -- @FirmGroup: группа фирма, 7 - Морозко, 10-Рестория
as
begin

  -- список допустимы ID-ов с ценами и прочими атрибутами:
  create table #i (id int, Ngrp smallint, Parent smallint, MainParent smallint, 
    MaxNcom int, hitag int, price decimal(10,2), flgWeight bit default 0, weight decimal(10,2),
    SrokH int, BarCode varchar(20), cost decimal(10,2), MinP int, Country varchar(50)); 

  -- Внесем туда список кодов, и для каждого кода выясним последнюю поставку:
  insert into #i(Hitag, MaxNcom)
    select v.Hitag, max(Ncom)
    from 
      tdvi v
      inner join firmsconfig fc on fc.Our_id=v.OUR_ID 
      inner join SkladList S on S.SkladNo=v.sklad
      inner join SkladGroups g on s.skg=g.skg
      and g.plid=@PLID
    where 
      v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0
      and fc.FirmGroup=@FirmGroup
    group by v.Hitag;

  -- Список попавших в пайс-лист кодов товаров:
  create table #h(hitag int, MaxId int);
  insert into #h 
      select #i.hitag,  max(v.id) as MaxId
      from #i
      inner join tdvi v on v.hitag=#i.hitag
      inner join firmsconfig fc on fc.Our_id=v.OUR_ID 
      inner join SkladList S on S.SkladNo=v.sklad
      inner join SkladGroups g on s.skg=g.skg
    where 
      v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0
      and g.plid=@PLID
      and fc.FirmGroup=@FirmGroup
    group by #i.hitag

    
  -- Подберем подходящие ID товаров:  
  update #i
    set ID=#H.MaxID 
    from 
      #i 
      inner join #h on #h.hitag=#i.hitag

  update #i 
    set Price=v.price, Weight=iif(v.weight=0, nm.Netto, v.Weight), 
    Ngrp=nm.Ngrp, Parent=GR.Parent, MainParent=gr.MainParent, 
    flgWeight=nm.flgWeight, 
    SrokH=DATEDIFF(DAY, ISNULL(v.DATER,0), ISNULL(v.SROKH,0)),
    MinP=V.MinP, BarCode=nm.barcode, Country=V.Country, Cost=v.Cost
  from 
    #i 
    inner join tdvi v on v.id=#i.id
    inner join Nomen nm on nm.hitag=v.hitag
    inner join GR on Gr.Ngrp=nm.ngrp

  update #i set srokh=1000 where Srokh>1000;

  update #i set #i.ngrp=(select parent from GR where GR.ngrp=#i.ngrp and gr.levl=2)
    where #i.ngrp in (select ngrp from gr where levl=2);

  update #i set Price=Price/Weight, Cost=Cost/Weight where FlgWeight=1 and Weight>0; 

  SELECT g.mainparent as Parent, par.grpname as ParentName, g.grpname, #i.ngrp, #i.hitag, #i.barcode, 
    nm.name as NName,
    #i.Price, #i.Cost, #i.Minp, #i.Weight as Netto, 0 as Rest, #i.Country, #i.flgWeight, #i.srokH
  FROM 
    #i
    inner join GR Par on Par.ngrp=#i.Mainparent
    inner join GR G on G.Ngrp=#i.Ngrp
    inner join Nomen nm on nm.hitag=#i.hitag
  order by par.grpname, g.grpname, Name;


/*  
  insert into #i
    select v.id, v.hitag, v.price,v.weight
    from 
      tdvi v
      inner join firmsconfig fc on fc.Our_id=v.OUR_ID 
      inner join SkladList S on S.SkladNo=v.sklad
      inner join SkladGroups g on s.skg=g.skg
      and g.plid=@PLID
    where 
      v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0
      and fc.FirmGroup=@FirmGroup;
  select * from #i;

  -- Список допустимых кодов Hitag и последних поставок по каждому HITAG:
  create table #h (hitag int, Ncom int); 
  insert into #h
    select tdvi.Hitag, max(tdvi.ncom)
    from 
      tdvi 
      inner join #i on #i.id=tdvi.id
    group by tdvi.Hitag;


  create table #P (Parent int, ParentName varchar(50),
    GrpName varchar(50), Ngrp int, Hitag int, Barcode varchar(20),
    Nname varchar(100), 
    Price decimal(10,2), Cost decimal(10,2), MinP int, Netto decimal(10,3),
    Rest int, Country varchar(50),
    flgWeight bit, SrokH int);
  
  create table #Z (Parent int, ParentName varchar(30),
    GrpName varchar(30), Ngrp int, Hitag int,Barcode varchar(20),
    Nname varchar(100), 
    Price decimal(10,2), Cost decimal(10,2), MinP int, Netto decimal(10,3),
    Rest int, Country varchar(50),
    flgWeight bit, SrokH int);
  
--*****************************************************************************************************
--**         ВЕСОВЫЕ ТОВАРЫ.                                                                         **
--*****************************************************************************************************
  create table #W (hitag iNt, MaxWeight decimal(10,3), Price decimal(10,2), Cost decimal(12,5), RestW decimal(10,3),
    Price1kg decimal(10,2), Cost1kg decimal(10,2));

  insert into  #w(Hitag, MaxWeight) 
  select h.hitag, v.weight
  from 
    #h

    tdvi v
    inner join #i on #i.id=v.id
    inner join Nomen nm on nm.hitag=V.hitag
    inner join #sk on #sk.sklad=v.SKLAD
  where 
    nm.flgWeight=1

  update #w set Price=(select top 1 price from tdvi where hitag=#w.hitag and weight=#w.Maxweight);
  update #w set Cost=(select top 1 Cost from tdvi where hitag=#w.hitag and weight=#w.Maxweight);
  update #w set Price1kg=Price/MaxWeight, Cost1kg=Cost/MaxWeight;



  insert into #P
  select 
    g2.Ngrp as Parent, g2.GrpName as ParentName,
    gr.GrpName, nm.ngrp, nm.hitag, nm.barcode,
    case when nm.fname is null or nm.fname='' then nm.name else nm.fname end as NNAME,
    #w.price1kg, #w.cost1kg,
    v.MinP, 
    sum(v.weight*(v.morn-v.sell+v.isprav-v.remov-v.bad)) as Netto,
    sum(v.morn-v.sell+v.isprav-v.remov-v.bad) as Rest,
    PR.ProducerName as Country,
    cast(1 as bit) as flgWeight,
    max(DATEDIFF(DAY, ISNULL(v.DATER,0), ISNULL(v.SROKH,0))) AS srokh   
  from 
    tdvi v 
    inner join #w on #w.hitag=v.hitag
    inner join nomen nm on nm.hitag=v.hitag
    inner join SkladList SL on SL.skladno=v.sklad
    inner join SkladGroups SG on SG.skg=SL.skg    
    inner join GR on GR.Ngrp=nm.ngrp
    inner join GR G2 on G2.Ngrp=GR.Parent
    left join Producer PR on PR.ProducerID=nm.LastProducerID
  where 
    SG.PLID=@PLID 
    and g2.ngrp not in (86)
    and v.locked=0 and (nm.name<>'' or nm.fname<>'')
    and gr.ngrp>0
    and nm.FlgWeight=1
    and gr.AgInvis=0
  group by 
    g2.ngrp, g2.GrpName,
    gr.GrpName, nm.ngrp,   nm.hitag, nm.barcode,
    case when nm.fname is null or nm.fname='' then nm.name else nm.fname end, 
    #w.price1kg, #w.cost1kg,
    v.MinP, 
    PR.ProducerName , datediff(day, getdate(), v.srokh)
  having sum(v.morn-v.sell+v.isprav-v.remov-v.bad)>0;



--*****************************************************************************************************
--**  ШТУЧНЫЕ ТОВАРЫ.                                                                                **
--*****************************************************************************************************
  insert into #P
  select 
    g2.Ngrp as Parent, g2.GrpName as ParentName,
    gr.GrpName, nm.ngrp, nm.hitag, nm.barcode,
    case when nm.fname is null or nm.fname='' then nm.name else nm.fname end as NNAME,
    max(v.price) as Price, max(v.cost) cost, nm.MinP, 
    iif(v.weight=0,nm.netto,v.weight) netto,
    sum(v.morn-v.sell+v.isprav-v.remov-v.bad) as Rest, 
    -- v.country,  -- так было
    PR.ProducerName as Country,
    cast(0 as bit) as flgWeight,
    -- 100 as srokh --  
    max(DATEDIFF(DAY, ISNULL(v.DATER,0), ISNULL(v.SROKH,0))) AS srokh   
  from 
    tdvi v 
    inner join #sk on #sk.sklad=v.SKLAD
    inner join SkladList SL on SL.skladno=v.sklad
    inner join SkladGroups SG on SG.skg=SL.skg
    inner join nomen nm on nm.hitag=v.hitag
    inner join GR on GR.Ngrp=nm.ngrp
    inner join GR G2 on G2.Ngrp=GR.Parent
    left join Producer PR on PR.ProducerID=nm.LastProducerID
  where 
    SG.PLID=@PLID 
    and g2.ngrp not in (86)
    and v.locked=0 and (nm.name<>'' or nm.fname<>'')
    and gr.ngrp>0
    and nm.flgWeight=0
    and gr.AgInvis=0
group by 
    g2.ngrp, g2.GrpName,
    gr.GrpName, nm.ngrp,   nm.hitag, nm.barcode,
    case when nm.fname is null or nm.fname='' then nm.name else nm.fname end, 
    nm.MinP, 
    iif(v.weight=0,nm.netto,v.weight),
    PR.ProducerName  , datediff(day, getdate(), v.srokh)
  having sum(v.morn-v.sell+v.isprav-v.remov-v.bad)>0
  ORDER by   
    g2.ngrp, gr.GrpName, case when nm.fname is null or nm.fname='' then nm.name else nm.fname end;
    

  update #P set Parent=Ngrp, ParentName=GrpName, Ngrp=999, GrpName='' where Parent=0;
  update #P set Srokh=0 where Srokh<0;


-- Избавляюсь от лишних цен:
  SELECT parent, parentname, grpname, ngrp, hitag, barcode, nname,
    max(Price) Price, MAX(Cost) Cost, Minp, max(Netto) Netto, SUM(Rest) Rest, Country, flgWeight, MAX(SrokH) SrokH
  FROM #P 
  GROUP BY
    parent, parentname, grpname, ngrp, hitag, barcode, nname,
    Minp, Country, flgWeight
  order by Parent, GrpName, Nname;
*/
end;