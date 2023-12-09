CREATE procedure ELoadMenager.eload_fl_vendors_statistics
@nd1 datetime, @nd2 datetime, @nom int =0
as
begin
set nocount on
declare @datnom int, @nd datetime
if object_id('tempdb..#dck') is not null drop table #dck
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#days') is not null drop table #days
create table #dck(dck int, nst bit default 0)
create nonclustered index dck_idx on #dck(dck)

insert into #dck --рестория
select distinct dck,0 from dbo.defcontract where actual=1 and our_id in (select our_id from dbo.firmsconfig where firmgroup=10)

insert into #dck --Красное и белое
select distinct dck,1 from dbo.defcontract where actual=1 and pin in (
select pin from dbo.def where master in (45247,43363,41782,37008))
except select dck,1 from #dck

insert into #dck --логистика
select dck,0 from dbo.defcontract where dck in (32757,32772,35856,47958,45004,59136,67333,36896)
except select dck,0 from #dck

set @nd=cast(@nd1 as datetime)
set @datnom=iif(isnull(@nom,0)=0,0,dbo.indatnom(@nom,@nd))
select oblname [область], rname [район], grp [фирма], ncod [код_постащика], fam [поставщик], pin [код_покупателя], brname [покупатель], place [регион], gpaddr [адрес_доставки], [day] [день_недели], [safe] [отгрузка_по_ответке], 
			 [avg_w] [загрузка], [box] [коробок]
into #res
from (
select o.oblname, ra.rname, g.firmsgroupname [grp], ve.ncod, ve.fam, r.place, d.pin, d.brname, d.gpAddr, datepart(weekday,c.nd) [ord], datename(weekday,c.nd) [day], 
			 cast(iif(c.stip=4,1,0)as bit) [safe], cast(sum(iif(n.flgweight=0,n.brutto*v.kol,s.weight)) as decimal(15,2)) [avg_w], cast(sum(v.kol*1.0 / n.minp) as decimal(15,2)) [box]
from dbo.nc c
join dbo.nv v with(index(nv_datnom_idx)) on c.datnom=v.datnom
join dbo.visual s on s.id=v.tekid
join dbo.nomen n on n.hitag=s.hitag
join dbo.inpdet i on i.id=s.startid
join dbo.comman co on co.ncom=i.ncom
join dbo.vendors ve on ve.ncod=co.ncod
join dbo.def d on d.pin=c.b_id
join dbo.regions r on r.reg_id=d.reg_id
join dbo.firmsconfig fc on fc.our_id=c.ourid
join dbo.firmsgroup g on g.firmsgroupid=fc.firmgroup
join dbo.raions ra on ra.rn_id=d.rn_id
join dbo.obl o on o.obl_id=ra.obl_id
where c.nd between @nd1 and @nd2 and c.mhid>0 and c.sp>0 and c.marsh<200 and v.kol>0 
			and c.datnom=iif(isnull(@datnom,0)=0,c.datnom,@datnom)
      and (exists(select 1 from #dck where dck=c.dck and nst=iif(ve.ncod=1665,1,nst)) or (ve.ncod=551) or (c.gpour_id=74402) or (c.gpour_id in (32757,32772,35856,47958,45004,59136,67333,36896))) --фильтры по договорам и Тарновскому и БА и Логистика
group by o.oblname, ra.rname, g.firmsgroupname,ve.ncod, ve.fam, d.pin, d.brname, d.gpAddr, datepart(weekday,c.nd), cast(iif(c.stip=4,1,0)as bit), datename(weekday,c.nd), r.place) x
order by grp, fam, [ord], place, brname, [safe]


select a.[код_покупателя],
			 stuff((select N','+#res.[день_недели]
       from #res where #res.[код_покупателя]=a.[код_покупателя]
       group by #res.[день_недели]
       for xml path(''), type).value('.','varchar(max)'),1,1,'') [дни_развоза]
into #days       
from (
select distinct [код_покупателя] from #res) a

select #res.*,#days.[дни_развоза] from #res
join #days on #days.[код_покупателя]=#res.[код_покупателя]

if object_id('tempdb..#dck') is not null drop table #dck
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#days') is not null drop table #days
set nocount off
end