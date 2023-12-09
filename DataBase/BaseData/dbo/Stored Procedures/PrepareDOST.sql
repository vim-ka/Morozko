CREATE procedure dbo.PrepareDOST @ND datetime, @OurList varchar(1000)
with RECOMPILE
AS
begin
  -- Список наших фирм:
  create table #O(OurID int);
  insert into #O select distinct K from dbo.Str2intarray(@OurList)

  create table #t (ID int, Act varchar(4), Sklad int,
    Hitag int, flgWeight bit, Rest decimal(10,3) default 0, 
    qtyIn decimal(10,3) default 0, qtyOut decimal(10,3) default 0,
    rubIn decimal(10,2) default 0, rubOut decimal(10,2) default 0,
    Cost decimal(12,5) default 0, OurID int default 0, 
    Netto decimal(10,3) default 0,
    Weight decimal(10,3) default 0);


if @nd=dbo.today() BEGIN
    -- Расчет поставок:
    insert into #t(id,Act,sklad, hitag, flgWeight, qtyIn,rubIn,OurID, Netto, Weight)
    select i.id, 'Прих',i.sklad, i.hitag, nm.flgWeight, 
      i.kol, i.kol*i.cost as RubIn, vi.our_id,
      nm.Netto, i.Weight
    from 
      inpdet i
      inner join comman cm on cm.ncom=i.ncom
      inner join nomen nm on nm.hitag=i.hitag
      inner join TDVI vi on vi.id=i.id
      inner join #o on #o.OurID=vi.OUR_ID
    where cm.date=@nd;


    -- Расчет продаж:
    insert into #t(id,Act,sklad, hitag, flgWeight, qtyOut,rubOut,OurID, Netto, Weight)
    select 
      nv.tekid, 'Прод', nv.sklad, nv.hitag, iif(vi.weight<>0 or nm.flgWeight=1,1,0),
      sum(nv.kol) qtyOut, sum(nv.kol*nv.cost) as rubOut, vi.our_id,
      nm.netto, vi.weight
    from NC 
      inner join nv on nv.datnom=nc.DatNom
      inner join nomen nm on nm.hitag=nv.Hitag
      inner join TDVI vi on vi.id=nv.tekid
      inner join #o on #o.OurID=vi.OUR_ID
    where nc.nd=@nd
    group by nv.tekid, nv.sklad, nv.hitag, iif(vi.weight<>0 or nm.flgWeight=1,1,0),
      vi.our_id, iif(vi.weight=0, nm.netto, vi.weight), nm.netto, vi.weight;

    
    -- Возвраты поставщику и коррекции остатков:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyIn,rubIn,ourID,Netto, Weight)
    select 
      iz.Id, iz.Act,  iz.Sklad, iz.Hitag, nm.flgWeight,
      sum(iz.newkol-iz.kol) as qtyIN,
      sum((iz.newkol-iz.kol)*iz.cost) as RubIn,
      vi.our_id, nm.Netto, vi.Weight
    from
      izmen iz
      inner join TDVI Vi on vi.id=iz.id  /* строка 12 */
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act in ('Снят', 'Испр')
    group by
      iz.Act, iz.Id, iz.Sklad, iz.Hitag, nm.flgWeight, vi.our_id, nm.Netto, vi.Weight
    having sum(iz.NewKol-iz.kol)<>0

    -- коррекция веса:
    insert into #t(id,act,sklad,hitag,flgWeight,ourID,qtyIn,rubIn, Netto,Weight)
    select
      iz.newid, iz.Act, iz.sklad, iz.hitag, nm.flgWeight, vi.our_id, 
      sum(iz.Newkol-iz.kol), sum((iz.Newkol-iz.kol)*iz.cost),
      nm.netto, vi.weight
    from
      izmen iz
      inner join TDVI vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=iz.newhitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='ИспВ' and iz.kol<>iz.newkol
    group BY
      iz.newid, iz.Act, iz.sklad, iz.hitag, nm.flgWeight, nm.netto, vi.weight, vi.our_id

    -- Перемещения между складами, расход:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyOut,rubOut,ourID,netto,weight)
    select
      iz.id, 'Скл-', iz.Sklad, iz.hitag, nm.flgWeight,
      sum(iz.kol) as qtyOut, sum(iz.kol*iz.cost) as rubOut, vi.our_id,
      nm.netto, vi.weight
    from
      izmen iz 
      inner join TDVI vi on vi.id=iz.id
      inner join Nomen nm on nm.hitag=vi.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd = @ND and iz.act='Скла' and iz.sklad<>iz.NewSklad
    group by
      iz.id, iz.Sklad, iz.hitag, nm.flgWeight,  nm.netto, vi.weight, vi.our_id;

    -- Перемещения между складами, приход:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyIn,rubIn,ourID,netto, weight)
    select
      iz.newid, 'Скл+', iz.newSklad, iz.hitag, nm.flgWeight,
      sum(iz.kol) as qtyIn, sum(iz.kol*iz.newcost) as rubIn, vi.our_id,
      nm.netto, vi.weight
    from
      izmen iz 
      inner join TDVI vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=vi.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd = @ND and iz.act='Скла' and iz.sklad<>iz.NewSklad
    group by
      iz.newid, iz.NewSklad, iz.hitag, nm.flgWeight,  nm.netto, vi.weight, vi.our_id;

    -- Операция Div- :
    insert into #t(id,act,sklad,hitag,flgWeight,qtyOut,rubOut,ourID,Netto, weight)
    select
      iz.id, 'div-', iz.sklad, iz.hitag,  
      nm.netto, vi.weight,
      sum(iz.kol-iz.NewKol) as qtyOut,
      sum(iz.cost*(iz.kol-iz.NewKol)) as rubOut,
      vi.our_id,iif(vi.weight>0,vi.weight,nm.netto)
    from
      izmen iz
      inner join TDVI vi on vi.id=iz.id and vi.hitag>0
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where
      iz.nd = @nd and iz.act='Div-'
    group BY
      iz.id, iz.act, iz.sklad, iz.hitag,  
      iif(vi.weight>0,vi.weight, nm.netto),
      vi.our_id,nm.netto, vi.weight;

    insert into #t(id,act,sklad,hitag,flgWeight,Netto,Weight,ourID,qtyIn,rubIn)
    select
      iz.newid, 'div+', iz.newsklad, iz.newhitag, nm.flgWeight,
      nm.netto, vi.Weight, vi.our_id,
      sum(iz.Newkol-iz.Kol) as qtyOut,
      sum(iz.cost*(iz.Newkol-iz.Kol)) as rubOut
    from
      izmen iz
      inner join TDVI vi on vi.id=iz.newid and vi.hitag>0
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where
      iz.nd = @nd and iz.act='Div+'
    group BY
      iz.newid, iz.newsklad, iz.newhitag, nm.flgWeight,
      nm.netto, vi.Weight,
      vi.our_id,iif(vi.weight>0,vi.weight,nm.netto)



    -- трансмутации, расход:
    insert into #t(id,act,sklad,hitag,flgWeight,Netto,weight,ourID,qtyOut,rubOut)
    select
      iz.id, 'TRN-', iz.sklad, iz.hitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id,
      sum(iz.kol), sum(iz.kol*iz.cost)
    from
      izmen iz
      inner join TDVI vi on vi.id=iz.id
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='tran'
    group BY
      iz.id, iz.sklad, iz.hitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id;

    -- трансмутации, приход:
    insert into #t(id,act,sklad,hitag,flgWeight,nm.netto,vi.weight,ourID,qtyOut,rubOut)
    select
      iz.newid, 'TRN+', iz.newsklad, iz.newhitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id,
      sum(iz.kol), sum(iz.kol*iz.cost)
    from
      izmen iz
      inner join TDVI vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=iz.newhitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='tran'
    group BY
      iz.newid, iz.newsklad, iz.newhitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id;

end;
else begin

    -- Расчет поставок:
    insert into #t(id,Act,sklad, hitag, flgWeight, qtyIn,rubIn,OurID, Netto,Weight)
    select i.id, 'Прих',i.sklad, i.hitag, nm.flgWeight, 
      i.kol, i.kol*i.cost as RubIn, vi.our_id,
      nm.netto, i.weight
    from 
      inpdet i
      inner join comman cm on cm.ncom=i.ncom
      inner join nomen nm on nm.hitag=i.hitag
      inner join visual vi on vi.id=i.id
      inner join #o on #o.OurID=vi.OUR_ID
    where cm.date=@nd;


    -- Расчет продаж:
    insert into #t(id,Act,sklad, hitag, flgWeight, qtyOut,rubOut,OurID, Netto,Weight)
    select 
      nv.tekid, 'Прод', nv.sklad, nv.hitag, iif(vi.weight<>0 or nm.flgWeight=1,1,0),
      sum(nv.kol) qtyOut, sum(nv.kol*nv.cost) as rubOut, vi.our_id,
      nm.netto, vi.weight
    from NC 
      inner join nv on nv.datnom=nc.DatNom
      inner join nomen nm on nm.hitag=nv.Hitag
      inner join visual vi on vi.id=nv.tekid
      inner join #o on #o.OurID=vi.OUR_ID
    where nc.nd=@nd
    group by nv.tekid, nv.sklad, nv.hitag, iif(vi.weight<>0 or nm.flgWeight=1,1,0),
      vi.our_id, nm.netto, vi.weight;

    
    -- Возвраты поставщику и коррекции остатков:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyIn,rubIn,ourID,Netto, weight)
    select 
      iz.Id, iz.Act,  iz.Sklad, iz.Hitag, nm.flgWeight,
      sum(iz.newkol-iz.kol) as qtyIN,
      sum((iz.newkol-iz.kol)*iz.cost) as RubIn,
      vi.our_id,
      nm.netto,vi.weight
    from
      izmen iz
      inner join Visual Vi on vi.id=iz.id  /* строка 12 */
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act in ('Снят', 'Испр')
    group by
      iz.Act, iz.Id, iz.Sklad, iz.Hitag, nm.flgWeight, vi.our_id, nm.netto,vi.weight
    having sum(iz.NewKol-iz.kol)<>0

    -- коррекция веса:
    insert into #t(id,act,sklad,hitag,flgWeight,Netto, weight,ourID,qtyIn,rubIn)
    select
      iz.newid, iz.Act, iz.sklad, iz.hitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id,
      sum(iz.Newkol-iz.kol), sum((iz.Newkol-iz.kol)*iz.cost)
    from
      izmen iz
      inner join visual vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=iz.newhitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='ИспВ' and iz.kol<>iz.newkol
    group BY
      iz.newid, iz.Act, iz.sklad, iz.hitag, nm.flgWeight, nm.netto, vi.Weight, vi.our_id


    -- Перемещения между складами, расход:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyOut,rubOut,ourID,Netto, weight)
    select
      iz.id, 'Скл-', iz.Sklad, iz.hitag, nm.flgWeight,
      sum(iz.kol) as qtyOut, sum(iz.kol*iz.cost) as rubOut, vi.our_id,
      nm.netto,vi.Weight
    from
      izmen iz 
      inner join visual vi on vi.id=iz.id
      inner join Nomen nm on nm.hitag=vi.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd = @ND and iz.act='Скла' and iz.sklad<>iz.NewSklad
    group by
      iz.id, iz.Sklad, iz.hitag, nm.flgWeight,  nm.netto,vi.Weight, vi.our_id;

    -- Перемещения между складами, приход:
    insert into #t(id,act,sklad,hitag,flgWeight,qtyIn,rubIn,ourID,Netto, weight)
    select
      iz.newid, 'Скл+', iz.newSklad, iz.hitag, nm.flgWeight,
      sum(iz.kol) as qtyIn, sum(iz.kol*iz.newcost) as rubIn, vi.our_id,
      nm.netto, vi.Weight
    from
      izmen iz 
      inner join visual vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=vi.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd = @ND and iz.act='Скла' and iz.sklad<>iz.NewSklad
    group by
      iz.newid, iz.NewSklad, iz.hitag, nm.flgWeight,nm.netto, vi.Weight, vi.our_id;

    -- Операция Div- :
    insert into #t(id,act,sklad,hitag,flgWeight,qtyOut,rubOut,ourID,Netto,weight)
    select
      iz.id, 'div-', iz.sklad, iz.hitag,  
      iif(vi.weight>0,vi.weight, nm.netto) as Weight,
      sum(iz.kol-iz.NewKol) as qtyOut,
      sum(iz.cost*(iz.kol-iz.NewKol)) as rubOut,
      vi.our_id,nm.netto,vi.weight
    from
      izmen iz
      inner join visual vi on vi.id=iz.id and vi.hitag>0
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where
      iz.nd = @nd and iz.act='Div-'
    group BY
      iz.id, iz.act, iz.sklad, iz.hitag,  
      iif(vi.weight>0,vi.weight, nm.netto),
      vi.our_id,nm.netto,vi.weight;

    insert into #t(id,act,sklad,hitag,flgWeight,Netto,weight,ourID,qtyIn,rubIn)
    select
      iz.newid, 'div+', iz.newsklad, iz.newhitag, nm.flgWeight,
      nm.netto, vi.Weight, vi.our_id as OurID,
      sum(iz.Newkol-iz.Kol) as qtyIn,
      sum(iz.cost*(iz.Newkol-iz.Kol)) as rubIn
    from
      izmen iz
      inner join visual vi on vi.id=iz.newid and vi.hitag>0
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where
      iz.nd = @nd and iz.act='Div+'
    group BY
      iz.newid, iz.newsklad, iz.newhitag, nm.flgWeight,
      iif(vi.weight>0,vi.weight, nm.netto),
      vi.our_id,nm.netto, vi.Weight



    -- трансмутации, расход:
    insert into #t(id,act,sklad,hitag,flgWeight,netto,weight,ourID,qtyOut,rubOut)
    select
      -- iz.id, 'TRN-', iz.sklad, iz.hitag, nm.flgWeight, nm.netto,vi.Weight, vi.our_id,
      iz.id, 'TRN-', iz.sklad, iz.hitag, nm.flgWeight, nm.netto, iz.weight, vi.our_id,
      sum(iz.kol), sum(iz.kol*iz.cost)
    from
      izmen iz
      inner join visual vi on vi.id=iz.id
      inner join Nomen nm on nm.hitag=iz.hitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='tran'
    group BY
      iz.id, iz.sklad, iz.hitag, nm.flgWeight, nm.netto, iz.weight, vi.our_id;

    -- трансмутации, приход:
    insert into #t(id,act,sklad,hitag,flgWeight,netto,weight,ourID,qtyOut,rubOut)
    select
    -- iz.newid, 'TRN+', iz.newsklad, iz.newhitag, nm.flgWeight, iif(vi.weight>0,vi.weight, nm.netto) as Weight, vi.our_id,
      iz.newid, 'TRN+', iz.newsklad, iz.newhitag, nm.flgWeight, nm.netto, iz.NewWeight as Weight, vi.our_id,
      sum(iz.newkol), sum(iz.kol*iz.cost)
    from
      izmen iz
      inner join visual vi on vi.id=iz.newid
      inner join Nomen nm on nm.hitag=iz.newhitag
      inner join #o on #o.OurID=vi.OUR_ID
    where iz.nd=@ND and iz.act='tran'
    group BY
      iz.newid, iz.newsklad, iz.newhitag, nm.flgWeight, nm.netto, iz.NewWeight, vi.our_id;

  end;


  update #t set qtyIn=-qtyOut, rubIn=-rubOut, qtyOut=0, rubOut=0 where qtyOut<0;
  update #t set qtyOut=-qtyIn, rubOut=-rubIn, qtyIn=0, rubIn=0 where qtyIn<0;
  update #t set qtyOut=qtyOut*Weight, qtyIn=qtyIn*weight where (qtyOut<>0 or qtyIn<>0) and flgWeight=1 and Weight>0;
  
  -- свернутая таблица:
  create table #s (ID int, Sklad int,
    Hitag int, flgWeight bit, Rest decimal(12,3) default 0, 
    qtyIn decimal(12,3) default 0, qtyOut decimal(12,3) default 0,
    rubIn decimal(12,2) default 0, rubOut decimal(12,2) default 0,
    Cost decimal(15,5) default 0, OurID int default 0, Netto decimal(12,3), weight decimal(12,3), 
    buh_id int default 0, VenPin int default 0, ncom int default 0, datepost datetime, zakup varchar(70), Box int );

  insert into #s(id,sklad,hitag,flgWeight,qtyIn,qtyOut,rubIn,rubOut,OurID,netto, weight)
  select id,sklad,hitag,flgWeight,
    sum(qtyIn), sum(qtyOut),
    sum(rubIn), sum(rubOut),
    OurID, netto, weight
  from #t
  group by id,sklad,hitag,flgWeight, OurID, netto, weight;

  create index s_temp_idx on #s(id);
  create index s_temp_idx2 on #s(sklad);

  update #s set datepost=v.datepost,ncom=v.ncom, venPin=def.pin 
    from #s inner join tdvi v on v.id=#s.id
    inner join Def on Def.Ncod=v.Ncod;
  update #s set datepost=v.datepost,
    ncom=v.ncom, venpin=def.pin
    from #s inner join visual v on v.id=#s.id 
    inner join Def on Def.Ncod=v.Ncod
    where #s.datepost is null;


  if @ND=dbo.today() begin
    update #s set cost=v.cost from #s inner join tdvi v on v.id=#s.id;
    update #s set Rest=v.morn-v.sell+v.isprav-v.remov
      from #s inner join tdvi v on v.id=#s.id and v.sklad=#s.Sklad
  end;
  else begin
    update #s
    set cost=a.cost, rest=a.eveningrest
    from 
      #s
      inner join morozarc..arcvi a on a.id=#s.id and a.sklad=#s.sklad
    where a.workdate=@nd
  end;

print('STAGE 1');
  update #s set rest=rest*weight, cost=cost/weight where flgWeight=1 and weight<>0;
print('STAGE 2');
  update #s set ncom=v.ncom, venpin=def.pin
  from #s inner join visual v on v.id=#s.id
  inner join def on def.ncod=v.ncod;
print('STAGE 3');
  update #s set weight=null where flgWeight=0;
print('STAGE 4');
  update #s set box=v.minp*v.mpu from #s inner join tdvi v on v.id=#s.id;
print('STAGE 5');
  update #s set box=v.minp*v.mpu from #s inner join visual v on v.id=#s.id where isnull(#s.box,0)=0;
  -- update #s set box=1 where box=0;
print('STAGE 6');
  update #s set Zakup=us.fio, buh_id=def.Buh_ID
  from 
    #s 
    inner join Def on Def.pin=#s.venpin
    inner join Usrpwd Us on us.uin=def.Buh_ID;
print('STAGE 7');

  
  select #s.*, nm.name, iif(nm.flgWeight=0,'шт','кг') as Units,
   def.brName as Postav,
   sl.SkladName, fc.FirmGroup, nm.FlgWeight as NomenFlgWeight, nm.Ngrp
  from 
    #s 
    inner join nomen nm on nm.hitag=#s.hitag
    left join Def on Def.pin=#s.venpin
    left join SkladList sl on sl.SkladNo=#s.Sklad
    inner join FirmsConfig fc on fc.our_id=#s.ourid
  order by id,sklad;
print('STAGE 8');

end;