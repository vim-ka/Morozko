-- Например, 19128,26512,26335,27352,31354,28322,32657,33033
--	112,551,218,73
create procedure dbo.RepMove @day0 datetime, @day1 datetime, @arHitag varchar(8000), @arSklad varchar(3000)
as
declare @DN0 int, @dn1 int, @sklUsed bit
BEGIN
  set @dn0 = dbo.fnDatNom(@day0, 1)
  set @dn1 = dbo.fnDatNom(@day1, 9999)
  
  -- список кодов товаров:
  create table #ht(hitag int);
  insert into #ht select * from dbo.Str2intarray(@arHitag);
  create index ht_temp_idx on #ht(hitag);

  -- список складов:
  create table #sk(sklad int);
  insert into #sk select * from dbo.Str2intarray(@arSklad);
  create index sk_temp_idx on #sk(sklad);
  
  set @sklUsed =iif(exists(select * from #sk),1,0);



  -- Таблица результатов расчета:
  create table #r(nd datetime, Hitag int, id int, Sklad int, Sell int default 0, Weight1 decimal(10,3));


  -- Список продаж:
  if @sklused=1
    insert into #r(nd,Hitag,id,sklad,sell)
    select nc.nd, nv.Hitag, nv.tekid, nv.sklad, sum(nv.kol) Sell
    from 
      nc
      inner join nv on nv.datnom=nc.datnom
      inner join #ht on #ht.hitag=nv.hitag
      inner join #sk on nv.sklad=#sk.sklad
    where nc.nd between @day0 and @day1
    group by nc.nd, nv.Hitag, nv.tekid, nv.sklad;
  ELSE
    insert into #r(nd,Hitag,id,sklad,sell)
    select nc.nd, nv.Hitag, nv.tekid, nv.sklad, sum(nv.kol) Sell 
    from 
      nc
      inner join nv on nv.datnom=nc.datnom
      inner join #ht on #ht.hitag=nv.hitag
    where nc.nd between @day0 and @day1
    group by nc.nd, nv.Hitag, nv.tekid, nv.sklad;

  update #r set Weight1=v.weight from #r inner join visual v on v.id=#r.id where v.weight>0;
  update #r set Weight1=v.weight from #r inner join tdvi v on v.id=#r.id where #r.weight1 is null and v.weight>0;

  update #r set Weight1=nm.netto from #r inner join nomen nm on nm.hitag=#r.hitag where #r.weight1 is null and nm.netto>0;


  select #r.*, nm.name from #r inner join Nomen nm on nm.hitag=#r.hitag  order by nd,Hitag, id,sklad;

end