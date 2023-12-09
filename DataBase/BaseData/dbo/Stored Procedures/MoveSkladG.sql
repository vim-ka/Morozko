CREATE PROCEDURE dbo.MoveSkladG @Comp varchar(16), @Nd0 datetime,  @Nd1 datetime
AS
declare @DN0 int, @DN1 int
declare @today datetime
BEGIN
  set @DN0=dbo.InDatNom(1,@Nd0)
  set @DN1=dbo.InDatNom(9999,@Nd1)
  set @today=convert(char(10), getdate(),104)

  -- Список нужных складов и кодов - уже в таблицах ReqSklad,ReqHitag.
  create table #TempTable (ND datetime,Hitag int, Act varchar(6), Qty decimal(12,3) );

  -- Поиск поставок в нашу фирму за период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select i.nd, i.hitag, 'INPUT' Act, sum(i.kol) Qty
    from Inpdet I inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=i.Hitag
    where i.ND between @ND0 and @ND1
    group by i.nd, i.hitag;  

  -- Поиск продаж за период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select dbo.DatNomInDate(nv.datnom) as ND, nv.hitag, 'SELL' as ACT, cast(sum(nv.kol) as integer) as Qty
    from NV inner join ReqSklad RS on RS.Sklad=NV.Sklad
    inner join ReqHitag RH on RH.Hitag=nv.Hitag
    where NV.datnom between @Dn0 and @Dn1
    group by dbo.DatNomInDate(nv.datnom), nv.hitag;
  
  -- Поиск исправлений остатков за предшествующий период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'ISPR' as ACT, cast(sum(i.newkol-i.kol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='испр'
    group by i.nd, v.hitag;

  -- Поиск исправлений остатков за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'ISPR' as ACT, cast(sum(i.newkol-i.kol) as integer) as Qty
    from Izmen I inner join TDVI V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today 
    and I.Act='испр'
    group by i.nd, v.hitag;
  
  -- Поиск перемещений со склада за предшествующий период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'SkMov-' as ACT, cast(sum(i.kol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='Скла'
    group by i.nd, v.hitag;
  -- То же за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'SkMov-' as ACT, cast(sum(i.kol) as integer) as Qty
    from Izmen I inner join tdvi V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today
    and I.Act='Скла'
    group by i.nd, v.hitag;
  
  -- Поиск перемещений НА СКЛАД за предшествующий период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'SkMov+' as ACT, cast(sum(i.kol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.NewSklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='Скла'
    group by i.nd, v.hitag;
  -- То же за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'SkMov+' as ACT, cast(sum(i.kol) as integer) as Qty
    from Izmen I inner join tdvi V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.NewSklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today
    and I.Act='Скла'
    group by i.nd, v.hitag;
    
  -- Поиск возвратов поставщикам за предшествующий период:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'REMOV' as ACT, cast(sum(i.kol-i.newkol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='Снят'
    group by i.nd, v.hitag;
  -- То же за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'REMOV' as ACT, cast(sum(i.kol-i.newkol) as integer) as Qty
    from Izmen I inner join tdvi V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today
    and I.Act='Снят'
    group by i.nd, v.hitag;

  -- Поиск разбиений товаров за пред.период;
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'Div-' as ACT, cast(sum(i.kol-i.newkol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='Div-'
    group by i.nd, v.hitag;
  -- То же за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'Div-' as ACT, cast(sum(i.kol-i.newkol) as integer) as Qty
    from Izmen I inner join tdvi V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today
    and I.Act='Div-'
    group by i.nd, v.hitag;
    
  -- Поиск слияний товаров за пред.период;
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'Div+' as ACT, cast(sum(i.newkol-i.kol) as integer) as Qty
    from Izmen I inner join Visual V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND<>@today
    and I.Act='Div+'
    group by i.nd, v.hitag;
  -- То же за сегодня:
  insert into #TempTable(Nd,Hitag,Act,Qty)
    select I.ND, V.hitag, 'Div+' as ACT, cast(sum(i.newkol-i.kol) as integer) as Qty
    from Izmen I inner join tdvi V on V.id=I.ID    
    inner join ReqSklad RS on RS.Sklad=I.Sklad
    inner join ReqHitag RH on RH.Hitag=V.Hitag
    where I.ND between @nd0 and @nd1 and I.ND=@today
    and I.Act='Div+'
    group by i.nd, v.hitag;
  
  
  SELECT Hitag, Nd, [Input],[Sell],[Ispr],[SkMov-],[Skmov+], [Remov],[Div-],[Div+]
  FROM #TempTable
  PIVOT (SUM(qty) FOR Act IN ([Input],[Sell],[Ispr],[SkMov-],[Skmov+], [Remov],[Div-],[Div+])) p
end;