CREATE PROCEDURE dbo.RentabGetAllData @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @with_actn bit, 
@calctip int, @isnet bit, @recalc bit, @withul bit
AS
BEGIN
SET NOCOUNT ON
declare 
@ym_from int,
@ym_to int,
@nds int,
@admc numeric(2, 1),
@retrobpost numeric(2, 1),
@mn int
set @admc = 4.5
set @mn = datepart(month, @day0)
if @mn < 10
  set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + '0' + convert(varchar(2), @mn))
else
  set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + convert(varchar(2), @mn))  
set @mn = datepart(month, @day1)    
if @mn < 10
  set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + '0' + convert(varchar(2), @mn))  
else
  set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + convert(varchar(2), @mn))

if object_id('tempdb..#temp') is not null drop table #temp
if object_id('tempdb..#temp1') is not null drop table #temp1

select 
cc.*,
round(ISNULL(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0), 2) result_rub,
round((ISNULL(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0) * 100) / isnull(cc.cost_rub, 0.1), 2) proc_zakup_cost,
round(isnull(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.retrob_post_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0), 2) itogo_rub,
round((isnull(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.retrob_post_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0)) * 100 / isnull(cc.cost_rub, 0.1), 2) itogo_proc_zakup_cost,
round((isnull(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.retrob_post_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0)) * 0.8, 2) itogo_withoutNNP,
round(((isnull(cc.naz_withoutNDS, 0) + isnull(cc.retrob_rub, 0) + isnull(cc.dost2_rub, 0) + isnull(cc.store_rub, 0) + isnull(cc.dost1_rub, 0) + isnull(cc.pers_rub, 0) + isnull(cc.adm_rub, 0) + isnull(cc.retrob_post_rub, 0) + isnull(cc.l_sum_opl, 0) + isnull(cc.l_sum_vozm, 0)) * 0.8) * 100 / isnull(cc.cost_rub, 0.1), 2) itogo_withoutNNP_proc
into #temp 
from
(
select
rc.obl_id, 
rc.ngrp, 
@ncod ncod,
isnull(rc.postvol, 0) postvol,
isnull(rc.postvol2, 0) postvol2,
rc.cost cost,
rc.cost * isnull(rc.postvol, 0) cost_rub,
rc.price price,
rc.price * isnull(rc.postvol, 0) price_rub,
round(((rc.price - rc.cost) / rc.price) * 100, 2) naz_proc,
round((rc.price - rc.cost) * rc.postvol, 2) naz_withNDS,
ROUND(rc.nds, 1) nds,
round(((rc.price * isnull(rc.postvol, 0)) - (rc.cost * isnull(rc.postvol, 0))) / (1 + rc.nds * 0.01), 2) naz_withoutNDS,
((rc.price * isnull(rc.postvol, 0) - rc.cost * isnull(rc.postvol, 0))) / isnull(rc.postvol, 0) naz_kg,
round((((rc.price * isnull(rc.postvol, 0)) - (rc.cost * isnull(rc.postvol, 0))) / isnull(rc.postvol, 0)) / (1 + rc.nds * 0.01), 2) naz_kg_withoutNDS,
-isnull(retrob.plata, 0) * 100 / rc.price * isnull(rc.postvol, 0) retrob_coeff,
-isnull(retrob.plata, 0) retrob_rub,
isnull(dost2.koeff, 0) dost2_coeff,
-isnull(rc.postvol2, 0) * isnull(dost2.koeff, 0) dost2_rub,
isnull(st.cost1kgstor, 0) cost1kgstor,
isnull(rcd.days, 0) days_stor,
-isnull(rc.postvol2, 0) * isnull(st.cost1kgstor, 0) * isnull(rcd.days, 0) store_rub,
isnull(dost1.koeff, 0) dost1_coeff,
-isnull(rc.postvol2, 0) * isnull(dost1.koeff, 0) dost1_rub,
round(((8 + 0.14) * 1.33), 2) pers_proc,
round(-((rc.price * isnull(rc.postvol2, 0)) - (rc.cost * isnull(rc.postvol2, 0))) * ((8 + 0.14) * 1.33) * 0.01, 2) pers_rub,
@admc adm_coeff,
-isnull(rc.postvol2, 0) * @admc adm_rub,
round(-isnull(rcl.l_sum_opl, 0), 2) l_sum_opl,
round(isnull(rcl.l_sum_vozm, 0), 2) l_sum_vozm,
isnull(@retrobpost, 0) retrob_post_coeff,
round(rc.cost * isnull(rc.postvol, 0) * isnull(@retrobpost, 0) * 0.01, 2) retrob_post_rub,
rc.hitag
from
dbo.RentabCalc rc
left join (select avg(gr.Cost1kgStor) Cost1kgStor, mainparent ngrp from gr group by mainparent) st on st.ngrp = rc.ngrp
left join (select ym_from, ym_to, obl_id, koeff from dbo.RentabCalcDost where ncod = @ncod and tip = 1) dost1 on dost1.ym_from = rc.ym_from and dost1.ym_to = rc.ym_to and dost1.obl_id = rc.obl_id
left join (select ym_from, ym_to, obl_id, koeff, ngrp from dbo.RentabCalcDost where ncod = @ncod and tip = 2) dost2 on dost2.ym_from = rc.ym_from and dost2.ym_to = rc.ym_to and dost2.obl_id = rc.obl_id and dost2.ngrp = rc.ngrp
left join (select ym_from, ym_to, obl_id, plata, ncod, ngrp, hitag from dbo.rentabcalcretrob) retrob on retrob.ym_from = rc.ym_from and retrob.ym_to = rc.ym_to and retrob.obl_id = rc.obl_id and retrob.ncod = @ncod and retrob.ngrp = rc.ngrp and retrob.hitag = rc.hitag
left join (select ym_from, ym_to, obl_id, days, ncod, ngrp from dbo.rentabcalcdays where ncod = @ncod) rcd on rcd.ym_from = rc.ym_from and rcd.ym_to = rc.ym_to and rcd.obl_id = rc.obl_id and rcd.ncod = @ncod and rcd.ngrp = rc.ngrp
left join (select ym_from, ym_to, obl_id, l_sum_opl, l_sum_vozm, ngrp, code from dbo.RentabCalcListing where ncod = @ncod) rcl on rcl.ym_from = rc.ym_from and rcl.ym_to = rc.ym_to and rcl.obl_id = rc.obl_id and rcl.ngrp = rc.ngrp and rcl.code = rc.hitag
where
rc.ym_from = @ym_from and rc.ym_to = @ym_to
and rc.ncod in --(@ncod)
(select @ncod union 
select ncod from RentabUrLicaDet 
where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
and rc.ngrp in (select ngrp from dbo.gr where (mainparent = @ngrp or @ngrp = -1))
and rc.calctip = @calctip
and rc.calcvid = 1
and rc.postvol <> 0
and rc.price <> 0
and rc.cost <> 0
and rc.nds <> 0
) cc
order by cc.obl_id, ngrp

--select * from #temp

select  
	t.obl_id, 
	(select oblname from dbo.obl where obl_id = t.obl_id) oblname, 
	t.ngrp, 
	(select grpname from dbo.gr where ngrp = t.ngrp) ngrp_name, 
	t.ncod,
    sum(t.postvol) postvol,
    sum(t.postvol2) postvol2,
    round(sum(t.cost * t.postvol) / sum(t.postvol), 3) cost,
    sum(t.cost * t.postvol) cost_rub,
    round(sum(t.price * t.postvol) / sum(t.postvol), 3) price,
    sum(t.price * t.postvol) price_rub,
    AVG(t.nds) nds,
    round(sum(t.retrob_rub) * 100 / (avg(t.price) * sum(t.postvol)), 2) retrob_coeff,
    round(sum(t.retrob_rub), 2) retrob_rub,
    round(avg(t.dost2_coeff), 2) dost2_coeff, 
    round(sum(t.dost2_rub), 2) dost2_rub,
    round(avg(t.cost1kgstor), 2) cost1kgstor, 
    avg(t.days_stor) days_stor, 
    round(sum(t.store_rub), 2) store_rub,
    round(avg(t.dost1_coeff), 2) dost1_coeff, 
    round(sum(t.dost1_rub), 2) dost1_rub,
    round(avg(t.pers_proc), 2) pers_proc, 
    round(sum(t.pers_rub), 2) pers_rub, 
    round(avg(t.adm_coeff), 2) adm_coeff, 
    round(sum(t.adm_rub), 2) adm_rub,
    round(sum(t.l_sum_opl), 2) l_sum_opl, 
    round(sum(t.l_sum_vozm), 2) l_sum_vozm,
    round(avg(t.retrob_post_coeff), 2) retrob_post_coeff, 
    round(sum(t.retrob_post_rub), 2) retrob_post_rub,
    round(sum(t.result_rub), 2) result_rub,
    round((sum(((t.price * isnull(t.postvol, 0)) - (t.cost * isnull(t.postvol, 0))) / (1 + t.nds * 0.01)) + sum(t.retrob_rub) +
    sum(t.dost2_rub) + sum(t.store_rub) + sum(t.dost1_rub) + sum(t.pers_rub) + sum(t.adm_rub) + 
    sum(t.l_sum_opl) + sum(t.l_sum_vozm)) * 100 / (avg(t.cost) * sum(t.postvol)), 2) proc_zakup_cost,
    
    round(sum(t.itogo_rub), 2) itogo_rub, 
    
    round((sum(((t.price * isnull(t.postvol, 0)) - (t.cost * isnull(t.postvol, 0))) / (1 + t.nds * 0.01)) + sum(t.retrob_rub) +
    sum(t.dost2_rub) + sum(t.store_rub) + sum(t.dost1_rub) + sum(t.pers_rub) + sum(t.adm_rub) + sum(t.retrob_post_rub) +
     sum(t.l_sum_opl) + sum(t.l_sum_vozm)) * 100 / (avg(t.cost) * sum(t.postvol)), 2) itogo_proc_zakup_cost, 
    
   round(sum(t.itogo_withoutNNP), 2) itogo_withoutNNP, 
    
    round(((sum(((t.price * isnull(t.postvol, 0)) - (t.cost * isnull(t.postvol, 0))) / (1 + t.nds * 0.01)) + sum(t.retrob_rub) +
    sum(t.dost2_rub) + sum(t.store_rub) + sum(t.dost1_rub) + sum(t.pers_rub) + sum(t.adm_rub) + sum(t.retrob_post_rub) +
     sum(t.l_sum_opl) + sum(t.l_sum_vozm)) * 0.8) * 100 / (avg(t.cost) * sum(t.postvol)), 2) itogo_withoutNNP_proc
into #temp1        
from 
	#temp t
group by t.obl_id, t.ngrp, t.ncod
order by t.obl_id, t.ngrp

select 
  t1.*,
  ROUND(((t1.price - t1.cost) / t1.price) * 100, 2) naz_proc,
  ROUND((t1.price * t1.postvol) - (t1.cost * t1.postvol), 2) naz_withNDS,
  round(((t1.price - t1.cost) * t1.postvol) / (1 + t1.nds * 0.01), 2) naz_withoutNDS,
  round((t1.price - t1.cost) / t1.postvol, 2) naz_kg,
  round(((t1.price - t1.cost) / t1.postvol) / (1 + t1.nds * 0.01), 2) naz_kg_withoutNDS
from 
  #temp1 t1
END