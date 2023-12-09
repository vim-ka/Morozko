CREATE PROCEDURE dbo.RecalcKolB @day0 datetime, @day1 datetime
AS
BEGIN
declare
@dn1 int,
@dn2 int,
@newnvid int,
@newkolb int,
@nvid int,
@ispr int,
@datnom int,
@hitag int,
@refdatnom int,
@tekid int,
@kol int,
@price numeric(12, 2),
@cost numeric(12, 2),
@kol_b int,
@sklad int,
@baseprice numeric(12, 2),
@remark varchar(255),
@tip int,
@meas int,
@delivcancel bit,
@origprice numeric(12, 2),
@ag_id int,
@retkol int


set @dn1 = dbo.InDatNom(0001, @day0)
set @dn2 = dbo.InDatNom(9999, @day1)

if OBJECT_ID('tempdb..#nvs') is not null drop table #nvs
	
/*create table #nvs(hitag int, tekid int, delta int, sklad int, price numeric(12, 2), weight numeric(12, 2), 
nds int, Cost numeric(12, 2), Extra numeric(6, 2), nvid int, reftekid int, refdatnom int, dck int, 
Ag_Id int, Srok int, actn bit, frizer bit, b_id int, StfNom varchar(20), StfDate datetime, DocNom varchar(20), DocDate datetime, flgweight bit)

insert into #nvs
select nv.hitag, nv.tekid, nv.kol_b - nv.kol delta, nv.sklad, nv.price, iif(z.curWeight is null, 0,  z.curWeight) curWeight, 
n.nds, nv.Cost, nc.Extra, nv.nvid, nv.tekid reftekid, nv.datnom refdatnom, nc.dck, nc.Ag_Id, nc.Srok, nc.actn, nc.frizer, nc.b_id, 
nc.StfNom, nc.StfDate, nc.DocNom, nc.DocDate, n.flgweight
from nv 
inner join nc on nc.datnom = nv.datnom
inner join nomen n on n.hitag = nv.hitag
left join nvzakaz z on z.datnom = nv.datnom and z.hitag = nv.hitag
where nv.datnom >= @dn1 and nv.datnom <= @dn2 and nv.kol_b > nv.kol
and nv.kol > 0
order by nv.nvid, nv.datnom, nv.hitag*/

create table #nvs(nvid int, datnom int, tekid int, hitag int, kol int, kol_b int, sklad int, price numeric(12, 2), cost numeric(12, 2))
insert into #nvs
select nv.nvid, nv.datnom, nv.tekid, nv.hitag, nv.kol, nv.kol_b, nv.sklad, nv.price, nv.Cost
from nv 
where 
nv.datnom >= @dn1 
and nv.datnom <= @dn2 
and nv.kol_b > nv.kol
and nv.kol > 0
order by nv.nvid, nv.datnom, nv.hitag

--update nv set kol_b = kol where nvid in (select nvid from #nvs)

--SELECT #nvs.* FROM #nvs

select nv.nvid, nv.datnom, nv.tekid, nv.hitag, nv.kol, nv.kol_b, nv.sklad, nv.price, nv.cost from dbo.nv 
inner join #nvs n on n.datnom = nv.datnom and n.hitag = nv.hitag
order by nv.datnom, nv.hitag

--inner join nc on nc.refdatnom = #nvs.datnom
--select nv.nvid, nv.datnom, nv.tekid, nv.hitag, nv.kol, nv.kol_b, nv.sklad, nv.price, nv.cost 
--from dbo.nv 
--where nv.datnom = #nvs.datnom and nv.hitag = #nvs.hitag
--inner join nc on nc.refdatnom = nv.datnom

/*if OBJECT_ID('tempdb..#rvs') is not null drop table #rvs
--create table #rvs(refdatnom int, datnom int, kol int, retkol int, hitag int, tekid int, cost numeric(12, 2), price numeric(12, 2))

create table #rvs(datnom int, hitag int, tekid int, kol int, kol_b int)

create table #rvt(datnom int, hitag int, tekid int, kol int, kol_b int)


declare CC cursor FAST_FORWARD FOR select nvid, datnom, tekid, hitag, kol, price, cost, kol_b, sklad from #nvs
open CC;
FETCH NEXT from CC INTO @nvid, @datnom, @tekid, @hitag, @kol, @price, @cost, @kol_b, @sklad;
WHILE (@@FETCH_STATUS=0) 
BEGIN
	if @kol < @kol_b 
    begin
      insert into #rvs 
	  select 
      nv.datnom, hitag, tekid, kol, kol_b
      from
      nc inner join nv on nv.datnom = nc.datnom
      where
      nc.datnom = @datnom
      and nv.hitag = @hitag
    end
    else
    begin
      insert into #rvt 
	  select 
      nv.datnom, hitag, tekid, kol, kol_b
      from
      nc inner join nv on nv.datnom = nc.datnom
      where
      nc.datnom = @datnom
      and nv.hitag = @hitag
    end
      
/*    select nc.refdatnom, nc.datnom, nv.kol, nv.hitag, nv.tekid
	from nv 
	inner join nc on nc.datnom = nv.datnom
	where 
	nc.RefDatnom = @datnom
	and nv.hitag = @hitag
	and nv.TekID = @tekid*/
    
/*	select @datnom, nc.datnom, sum(nv.kol), @kol_b - @kol, nv.Hitag, nv.tekid, @cost, @price from nv 
    inner join nc on nc.datnom = nv.datnom
    where 
    tekid = @tekid and
    hitag = @hitag and kol > 0 and kol_b = 0
    and nc.RefDatnom <> @datnom
    --and nv.Price = @price
    --and nv.cost = @cost
    --and nv.sklad = @sklad
    --and kol >= @kol_b - @kol    
    group by nc.datnom, nv.Hitag, nv.tekid
    having sum(nv.kol) >= @kol_b - @kol*/
    
--  set @newkolb = @kol_b - @kol
  
--  select @newkolb = isnull(nv.kol_b + @ispr, 0), @newnvid = isnull(nv.nvid, 0) 
--  from dbo.nv where nv.nvid <> @nvid and nv.datnom = @datnom and nv.hitag = @hitag
--  and nv.nvid = (select min(n.nvid) FROM nv n WHERE n.datnom = nv.datnom AND n.hitag = nv.hitag AND n.nvid <> @nvid)
--  and nv.kol_b + @ispr <= nv.kol

--  print @newnvid
--  print @refdatnom 
--  print @retkol
--  print @newkolb
  
  --update dbo.nv set kol_b = @newkolb where nv.nvid = @newnvid
  FETCH NEXT from CC INTO @nvid, @datnom, @tekid, @hitag, @kol, @price, @cost, @kol_b, @sklad;
END
close CC;
deallocate CC;*/

--select * from #rvs
--select * from #rvt

/*select nv.nvid, nv.datnom, nv.Hitag, nv.kol, nv.kol_b, #nvs.ispr, nv.Kol_B + #nvs.ispr itog from nv 
inner join #nvs on #nvs.datnom = nv.datnom and #nvs.hitag = nv.hitag
where
#nvs.nvId <> nv.nvid 
AND nv.Kol_B + #nvs.ispr <= nv.kol
AND nv.nvId = (SELECT min(n.nvid) FROM nv n WHERE n.datnom = nv.datnom AND n.hitag = nv.hitag AND n.nvid <> #nvs.nvid)
ORDER BY nv.nvid, nv.datnom, nv.hitag*/

END