create procedure ELoadMenager.eload_period_loads_vendor_client
@nd1 datetime, @nd2 datetime, @ncod varchar(500) ='', @pin varchar(500) =''
as 
begin
set nocount on;
if object_id('tempdb..#_vend') is not null drop table #_vend
if object_id('tempdb..#_buy') is not null drop table #_buy
if object_id('tempdb..#_nomen') is not null drop table #_nomen
create table #_vend (ncod int); create nonclustered index _vend_idx on #_vend(ncod);
create table #_buy (pin int); create nonclustered index _buy_idx on #_buy(pin);
create table #_nomen (hitag int); create nonclustered index _nomen_idx on #_nomen(hitag);
if @ncod<>'' insert into #_vend select value from string_split(@ncod,',')
else insert into #_vend select ncod from dbo.vendors;
if @pin<>'' insert into #_buy select value from string_split(@pin,',')
else insert into #_buy select pin from dbo.def;
insert into #_buy select pin from dbo.def where master in (select abs(pin) from #_buy where pin<0);
delete from #_buy where pin<0;
insert into #_nomen
select i.hitag
from dbo.comman m
join dbo.inpdet i on i.ncom=m.ncom
join #_vend on #_vend.ncod=m.ncod
group by i.hitag;

select n.hitag [код товара], n.name [наименование], 
			 case when n.flgweight=1 and isnull(isnull(t.weight,s.weight),0)>0 then v.price / isnull(t.weight,s.weight)
           	when n.flgweight=1 and isnull(isnull(t.weight,s.weight),0)<=0 then 0
       else v.price end [цена],
       sum(iif(n.flgweight=1,isnull(isnull(t.weight,s.weight),0)*v.kol,v.kol)) [количество],
       sum(v.kol*v.price) [стоимость] 
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.tdvi t on t.id=v.tekid
left join dbo.visual s on s.id=v.tekid
join #_buy on #_buy.pin=c.b_id
join #_nomen on #_nomen.hitag=v.hitag
where c.nd between @nd1 and @nd2 and c.stip<>4
			and c.sp>0
group by n.hitag, n.name, case when n.flgweight=1 and isnull(isnull(t.weight,s.weight),0)>0 then v.price / isnull(t.weight,s.weight)
           										 when n.flgweight=1 and isnull(isnull(t.weight,s.weight),0)<=0 then 0
       										else v.price end
                          
if object_id('tempdb..#_vend') is not null drop table #_vend;
if object_id('tempdb..#_buy') is not null drop table #_buy;
if object_id('tempdb..#_nomen') is not null drop table #_nomen;
set nocount off;
end