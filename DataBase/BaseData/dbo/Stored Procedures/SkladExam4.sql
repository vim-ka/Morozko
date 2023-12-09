create procedure dbo.SkladExam4 @Day0 datetime, @Day1 datetime, 
  @SkladList varchar(3000)='', @HitagList varchar(8000)='', 
  @SkladListUsed bit=1
as
begin

create table #h(hitag int);
insert into #h select k from dbo.str2intarray(@hitaglist);

-- Для отладки: 380 строк с кодами колбасы:
-- insert into #h select distinct hitag from tempsver;

print('таблица #h заполнена');

create index htg_tmp_idx on #h(hitag);


if @SkladListUsed=1 begin
  create table #s(Sklad int);
  insert into #s select k from dbo.str2intarray(@SkladList);
  if not exists (select * from #s)
    insert into #s select skladno from skladlist;
  create index tmp_sklad_idx on #s(sklad)
END

create table #t(ND datetime, id int, hitag int, sklad int, 
  Inp int default 0,
  TranP int default 0,TranM int default 0,
  DivP int default 0, Divm int default 0,
  Ispr int default 0, IspV int default 0,
  SkladP int default 0, SkladM int default 0,
  Sell int default 0, BrBack int default 0, Remov int default 0
);

-- Приход:
if @SkladListUsed=1 
  insert into #t(nd, id,hitag,sklad,Inp)
  select i.nd, i.id,i.hitag,i.sklad,i.kol as Start
  from Inpdet i
  inner join #h on #h.hitag=i.hitag
  inner join #s on #s.sklad=i.sklad  
  where i.nd>=@Day0 and i.nd<=@Day1;
else
  insert into #t(nd, id,hitag,sklad,Inp)
  select i.nd, i.id,i.hitag,i.sklad,i.kol as Start
  from Inpdet i
  inner join #h on #h.hitag=i.hitag
  where i.nd>=@Day0 and i.nd<=@Day1;


-- Продажи и возвраты от покупателей:
if @SkladListUsed=1 begin
  insert into #t(nd, id,hitag,sklad,Sell)
    select nc.nd, nv.tekId, nv.hitag, nv.sklad, sum(nv.Kol) as Sell
    from
      nc 
      inner join nv on nv.datnom=nc.datnom
      inner join #h on #h.hitag=nv.hitag
      inner join #s on #s.sklad=nv.sklad
    where nc.nd>=@Day0 and nc.nd<=@Day1 and nv.kol>0
    group by nc.nd, nv.tekId, nv.hitag, nv.sklad;
  insert into #t(nd, id,hitag,sklad,BrBack)
    select nc.nd, nv.tekId, nv.hitag, nv.sklad, sum(-nv.Kol) as BrBack
    from
      nc 
      inner join nv on nv.datnom=nc.datnom
      inner join #h on #h.hitag=nv.hitag
      inner join #s on #s.sklad=nv.sklad
    where nc.nd>=@Day0 and nc.nd<=@Day1 and nv.kol<0
    group by nc.nd, nv.tekId, nv.hitag, nv.sklad;
end;
else begin
  insert into #t(nd,id,hitag,sklad,Sell)
    select nc.nd, nv.tekId, nv.hitag, nv.sklad, sum(nv.Kol) as Sell
    from
      nc 
      inner join nv on nv.datnom=nc.datnom
      inner join #h on #h.hitag=nv.hitag
    where nc.nd>=@Day0 and nc.nd<=@Day1 and nv.kol>0
    group by nc.nd, nv.tekId, nv.hitag, nv.sklad;
  insert into #t(nd,id,hitag,sklad,BrBack)
    select nc.nd, nv.tekId, nv.hitag, nv.sklad, sum(-nv.Kol) as BrBack
    from
      nc 
      inner join nv on nv.datnom=nc.datnom
      inner join #h on #h.hitag=nv.hitag
    where nc.nd>=@Day0 and nc.nd<=@Day1 and nv.kol<0
    group by nc.nd, nv.tekId, nv.hitag, nv.sklad;
end;

print('Продажи посчитаны');


-- Возврат поставщику:
if @SkladListUsed=1 
  insert into #t(nd, id,hitag,sklad,Remov)
  select i.nd, i.id, i.hitag, i.sklad, sum(i.kol-i.newkol) as Remov
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Снят'
    group by i.nd, i.id, i.hitag, i.sklad;
else
  insert into #t(nd,id,hitag,sklad,Remov)
  select i.nd,i.id, i.hitag, i.sklad, sum(i.kol-i.newkol) as Remov
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Снят'
    group by i.nd, i.id, i.hitag, i.sklad;


-- Перемещения между складами:
if @SkladListUsed=1 begin 
  insert into #t(nd, id,hitag,sklad,SkladM)
    select i.nd, i.Id, i.hitag, i.sklad, sum(i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
      inner join #s on #s.sklad=i.sklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Скла'
    group by i.nd, i.Id, i.hitag, i.sklad;
  insert into #t(nd, id,hitag,sklad,SkladP)
    select i.nd, i.Id, i.hitag, i.newsklad, sum(i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Скла'
    group by i.nd, i.Id, i.hitag, i.newsklad;
END;
else BEGIN
  insert into #t(nd,id,hitag,sklad,SkladM)
    select i.nd,i.Id, i.hitag, i.sklad, -sum(i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Скла'
    group by i.nd, i.Id, i.hitag, i.sklad;
  insert into #t(nd, id,hitag,sklad,SkladP)
    select i.nd, i.newId, i.hitag, i.newsklad, sum(i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Скла'
    group by i.nd, i.newId, i.hitag, i.newsklad;
end;


-- ОПЕРАЦИИ ИСПВ:
if @SkladListUsed=1 begin 
  insert into #t(nd, id,hitag,sklad,IspV)
    select i.nd, i.newId, i.hitag, i.sklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='ИспВ'
    group by i.nd, i.newId, i.hitag, i.sklad;
END;
else BEGIN
  insert into #t(nd,id,hitag,sklad,IspV)
    select i.nd, i.newId, i.hitag, i.sklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='ИспВ'
    group by i.nd, i.newId, i.hitag, i.sklad;
END;



-- ОПЕРАЦИИ ИСПР:
if @SkladListUsed=1 begin 
  insert into #t(nd,id,hitag,sklad,Ispr)
    select i.nd,i.Id, i.hitag, i.sklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Испр'
    group by i.nd,i.Id, i.hitag, i.sklad;
END;
else begin 
  insert into #t(nd,id,hitag,sklad,Ispr)
    select i.nd, i.Id, i.hitag, i.sklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Испр'
    group by i.nd, i.Id, i.hitag, i.sklad;
END;


-- ОПЕРАЦИИ DIV+, DIV-
if @SkladListUsed=1 begin 
  insert into #t(nd,id,hitag,sklad,DivP)
    select i.nd,i.NewId, i.newhitag, i.newsklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Div+'
    group by i.nd, i.NewId, i.newhitag, i.newsklad;
  insert into #t(nd,id,hitag,sklad,DivM)
    select i.nd,i.Id, i.hitag, i.sklad, sum(i.Kol-i.newKol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
      inner join #s on #s.sklad=i.sklad
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Div-'
    group by i.nd, i.Id, i.hitag, i.sklad;
end; 
ELSE BEGIN
  insert into #t(nd,id,hitag,sklad,DivP)
    select i.nd, i.NewId, i.newhitag, i.newsklad, sum(i.NewKol-i.Kol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.newhitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Div+'
    group by i.nd, i.NewId, i.newhitag, i.newsklad;
  insert into #t(nd, id,hitag,sklad,DivM)
    select i.nd, i.Id, i.hitag, i.sklad, sum(i.Kol-i.newKol) as Delta 
    from 
      izmen i 
      inner join #h on #h.hitag=i.hitag
    where i.nd>=@day0 and i.nd<=@day1 and i.Act='Div-'
    group by i.nd, i.Id, i.hitag, i.sklad;
end;




-- ОПЕРАЦИИ TRAN

if @SkladListUsed=1 begin 
  insert into #t(nd,id,hitag,sklad,TranP)
    select i.nd, i.newid, i.newHitag, i.newSklad,sum(i.newkol) as Delta
    from 
      izmen i
      inner join #h on #h.hitag=i.newhitag
      inner join #s on #s.sklad=i.newsklad
    where i.nd>=@day0 and i.nd<=@day1 and i.act='Tran' 
    group by i.nd,i.newid, i.newHitag, i.newSklad;
  insert into #t(nd,id,hitag,sklad,TranM)
    select i.nd, i.id, i.Hitag, i.Sklad,sum(-i.kol) as Delta
    from 
      izmen i
      inner join #h on #h.hitag=i.hitag
      inner join #s on #s.sklad=i.sklad
    where i.nd>=@day0 and i.nd<=@day1 and i.act='Tran' 
    group by i.nd, i.id, i.Hitag, i.Sklad;
end
else begin
  insert into #t(nd,id,hitag,sklad,TranP)
    select i.nd,i.newid, i.newHitag, i.newSklad,sum(i.newkol) as Delta
    from 
      izmen i
      inner join #h on #h.hitag=i.newhitag
    where i.nd>=@day0 and i.nd<=@day1 and i.act='Tran' 
    group by i.nd, i.newid, i.newHitag, i.newSklad;
  insert into #t(nd,id,hitag,sklad,TranM)
    select i.nd,i.id, i.Hitag, i.Sklad,sum(-i.kol) as Delta
    from 
      izmen i
      inner join #h on #h.hitag=i.hitag
    where i.nd>=@day0 and i.nd<=@day1 and i.act='Tran' 
    group by i.nd,i.id, i.Hitag, i.Sklad;
end;

select nd, 0 as id, hitag,sklad, sum(inp) Inp,
  sum(Sell) Sell, sum(BrBack) brBack, sum(Remov) Remov,
  sum(TranP) TranP, sum(TranM) TranM, 
  sum(DivP) DivP, sum(DivM) DivM, 
  sum(SkladP) SkladP, sum(SkladM) SkladM,
  sum(Ispr) Ispr, sum(IspV) IspV 
from #t
group by nd,hitag,sklad
order by nd,hitag,sklad,id;


--select count(distinct id) from #t;
--select distinct hitag from #t;
--select distinct sklad from #t;


END