create procedure Read1199izmen @day0 datetime, @day1 datetime
as
begin

  create table #t (nd datetime, hitag int, ncom int, price decimal(10,2), 
    nacen decimal(10,2), Kol int);
  
  -- Операции коррекции, возврата, исправления:
  insert into #t
    select i.nd,i.Hitag, i.Ncom, i.Price, 0 as nacen, sum(i.newkol-i.kol) as Kol
    from izmen i  
    where i.ncod=1199 and i.nd between @day0 and @day1
    and i.Act in ('div-', 'Испр', 'Снят')
    group by i.nd,i.Hitag, i.Ncom, i.Price;
    
  -- Операция tran, когда она работает в сторону уменьшения:
  insert into #t
    select i.nd,i.Hitag, i.Ncom, i.Price, 0 as nacen, sum(-i.kol) as Kol
    from izmen i  
    where i.ncod=1199 and i.nd between @day0 and @day1
    and i.Act='tran'
    group by i.nd,i.Hitag, i.Ncom, i.Price;
  
  -- Операция tran, когда она работает в сторону увеличения:
  insert into #t
    select i.nd,i.NewHitag as Hitag, vi.Ncom, i.NewPrice as Price, 0 as nacen, sum(i.Newkol) as Kol
    from izmen i  inner join Visual vi on vi.id=i.NewID
    where i.ncod=1199 and i.nd between @day0 and @day1
    and i.Act='tran'
    group by i.nd,i.NewHitag, vi.Ncom, i.NewPrice;
  
  select nd, hitag, ncom, price, sum(kol) as Kol
  from #t
  group by nd, hitag, ncom, price
  having sum(kol)<>0
  order by Nd, sum(kol)

END