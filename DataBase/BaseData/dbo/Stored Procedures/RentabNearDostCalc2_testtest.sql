CREATE PROCEDURE dbo.RentabNearDostCalc2_testtest @nd1 datetime, @nd2 datetime
AS
BEGIN
declare
@dn1 int,
@dn2 int

set @dn1 = dbo.InDatNom(0001, @nd1)
set @dn2 = dbo.InDatNom(9999, @nd2)

  if object_id('tempdb..#z') is not null drop table #z
--create table #z(depid int, b_id int, mhid int, mwgt numeric(12, 2), msum numeric(12, 2), sp int, datnom int)
create table #z(depid int, b_id int, mhid int, sp numeric(12, 2), datnom int, stip int, weight numeric(12, 2), sc numeric(12, 2))
insert into #z
select distinct
al.depid,
nc.b_id, 
nc.mhid,
--lpd.OplataSum + lpd.OplataOther + lpd.Bonus marsh_s,
nc.sp,
--(1 + nc.extra / 100) * nv.kol * nv.price, --sp
nc.datnom,
case when nc.stip <> 4 then 0 else 4 end stip,
m.Weight,
nc.sc
from 
nc
--inner join nv on nv.datnom = nc.datnom
inner join agentlist al on al.AG_ID = nc.Ag_Id
inner join marsh m on m.mhid = nc.mhid
--inner join NearLogistic.nlListPayDet lpd on lpd.mhid = nc.mhid
where
nc.datnom >= @dn1 and nc.datnom <= @dn2
and nc.mhid not in (0, -99)
--and nc.STip <> 4
and nc.frizer = 0 
and nc.tara = 0
and nc.weight <> 0
and isnull(m.SelfShip, 0) <> 1
and (nc.mhid > 0 or (nc.sp < 0 and nc.remark <> ''))
and nc.sp > 0


--select depid, sum(mwgt) sum_wgt, sum(sp) sum_sp, count(datnom) from #z
--group by depid

--select sum(sp), depid, stip from #z where depid = 3 group by depid, stip order by depid, stip
--select * from #z


-- Теперь свернем ее по номерам маршрутов - это понадобится, чтобы рассчитать 
-- полный вес каждого маршрута и соответственно долю каждой накладной:
if object_id('tempdb..#s') is not null drop table #s
create table #s (weight decimal(12, 3), sp decimal(10, 2), sc decimal(10,2), rashod decimal(10,2), kolnakl int, mhid int, stip int, depid int);
    
-- По-новой рассчитываю суммарный вес каждого маршрута за период:
insert into #s(weight, sp, sc, rashod, kolnakl, mhid, stip, depid)  
select 0 weight, --#z.weight weight,
       0 sp,
       0 sc, 
       0 rashod,
       (select count(datnom) from nc where mhid = #z.mhid),
       #z.mhid,
       #z.stip,
       #z.depid
from #z 
group by #z.mhid, #z.stip, #z.depid
order by #z.mhid

--select * from #s where #s.depid = 3

update #s set sp = (select sum(sp) from nc where mhid = #s.mhid and stip <> 4) where #s.stip <> 4
update #s set sp = (select sum(sp) from nc where mhid = #s.mhid and stip = 4) where #s.stip = 4
update #s set sc = (select sum(sc) from nc where mhid = #s.mhid and stip <> 4) where #s.stip <> 4
update #s set sc = (select sum(sc) from nc where mhid = #s.mhid and stip = 4) where #s.stip = 4

if object_id('tempdb..#t') is not null drop table #t
create table #t (mhid int, sp_all numeric(12, 2))
insert into #t
select ss.mhid, sum(ss.sp) from #s ss group by ss.mhid

--select * from #t where mhid = 322533

update #s set weight = isnull((select #s.sp / #t.sp_all * m.weight from dbo.marsh m inner join #t on #t.mhid = m.mhid where m.mhid = #s.mhid), 0)

if object_id('tempdb..#r') is not null drop table #r
create table #r (mhid int, r_all numeric(12, 2))
insert into #r
select distinct m.mhid, sum(isnull(m.oplatasum, 0) + isnull(m.percworkpay, 0) + isnull(m.Bonus, 0)) from nearlogistic.nllistpaydet m 
inner join #t ss on ss.mhid = m.mhid group by m.mhid

--select * from #s where mhid = 322533

--select * from #r where mhid = 322533

--update #s set rashod = isnull((select sum(m.oplatasum) + isnull(m.percworkpay, 0) + isnull(m.Bonus, 0)) from nearlogistic.nllistpaydet m where m.mhid = #s.mhid), 0)
update #s set rashod = isnull((select #s.sp / #t.sp_all * #r.r_all from #t inner join #r on #r.mhid = #t.mhid where #t.mhid = #s.mhid and #r.mhid = #s.mhid), 0)

--select * from #s where #s.depid = 3

--select sum(rashod) / sum(weight), depid, stip from #s where #s.depid = 3 group by depid, stip
--select round(sum(#s.rashod) / sum(#s.weight), 2) rub1kg, #s.depid, st.stip, st.Meaning, #z.b_id, d.master--, rud.ruid 
/*select round(sum(#s.rashod) / sum(#s.weight), 2) rub1kg, #s.depid, st.stip, st.Meaning, d.master--, rud.ruid 
from 
#s 
inner join #z on #z.depid = #s.depid and #z.stip = #s.stip
inner join dbo.NC_ShippingType st on st.STip = #s.stip
inner join dbo.def d on d.pin = #z.b_id
--left join dbo.RentabUrLicaDet rud on rud.ncod = #z.b_id and rud.calctip = 2 
group by #s.depid, st.stip, st.Meaning, d.master--, rud.ruid
order by #s.depid, d.master, st.stip*/


select #s.depid, dp.dname, st.Meaning, round(sum(#s.rashod) / sum(#s.weight), 2) rub1kg   
from 
#s 
inner join #z on #z.depid = #s.depid and #z.stip = #s.stip
inner join dbo.NC_ShippingType st on st.STip = #s.stip
--inner join dbo.def d on d.pin = #z.b_id
--left join dbo.RentabUrLicaDet rud on rud.ncod = #z.b_id and rud.calctip = 2 
inner join deps dp on dp.depid = #s.depid
group by #s.depid, st.Meaning, dp.dname
order by #s.depid 

--select *, rashod / iif(weight = 0, 1, weight) from #s 

--select sum(sp), sum(sc) from nc where mhid = 325812

--select sum(sp), sum(sc), (select weight from marsh where mhid = nc.mhid) from nc where nc.mhid = 325812 group by nc.mhid

--select isnull(m.oplatasum, 0) + isnull(m.percworkpay, 0) + isnull(m.Bonus, 0) from nearlogistic.nllistpaydet m where m.mhid = 325812

--select * from tdvi where hitag = 19533

--select * from nv where tekid = 84580893

END