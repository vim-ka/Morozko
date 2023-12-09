CREATE PROCEDURE dbo.ReqTorgTMain @df1 int, @df2 int, @df3 int, @df4 int, @nd1 datetime, @nd2 datetime
AS
if OBJECT_ID('tempdb..#r') is not null drop table #r
create table #r(nnak int, savedate datetime)
insert into #r
select rtt.newpin, h.savedate from ReqTorgT rtt
inner join Collectioner2.dbo.hdr h on h.nnak = rtt.newpin
where rtt.nd between @nd1 and @nd2
and h.ngrp in (58, 74, 155, 168, 183)
and h.savedate = (select max(savedate) from Collectioner2.dbo.hdr where ngrp in (58, 74, 155, 168, 183) and nnak = rtt.newpin)
 
create index r_temp_idx on #r(nnak);

select distinct
rtt.id,
rtt.naim,
--isnull(rtt.orgform, '') orgform,
case when rtt.orgformidx = 0 then 'ИП' 
when rtt.orgformidx = 1 then 'ООО' 
else '<не указано>' end orgform,
case when rtt.isseti = 1 then
	(select brName from def where def.pin = rtt.setiname)
else 'нет сети'
end seti,
rtt.uraddress,
rtt.factaddress,
rtt.ogrn,
rtt.inn,
isnull(rtt.kpp, '') kpp,
rtt.postav,
(select ourname from firmsconfig where our_id = rtt.postav) postav_name,
(SELECT doc_pref FROM dbo.FirmsConfigAdd WHERE our_id = rtt.postav GROUP BY doc_pref) + CAST(DATEPART(YEAR, rtt.dogovordate) AS VARCHAR(4)) +  '/' + isnull(rtt.dogovornum, '') dogovornum,
rtt.dogovordate,
rtt.otsrochka,
rtt.oplataform,
case when rtt.oplataform = 0 then 'нал' else 'безнал' end oplataform_naim,
rtt.banknaim,
rtt.bankrs,
rtt.bankcs,
rtt.bankbik,
rtt.contactlico,
rtt.phonett,
rtt.torgagent,
(select fio from person where p_id =  (select p_id from agentlist where ag_id = rtt.torgagent)) torgagent_fio,
rtt.supername,
rtt.regiondostavki,
(select place from regions where reg_id = rtt.regiondostavki) region_name,
rtt.categorytt,
rtt.squarett,
isnull(rtt.formattt, -1) formattt,
rtt.pokuptt,
rtt.coordttX,
rtt.coordttY,
case when rtt.pechat = 0 then 'да' else 'нет' end pechat,
rtt.nd,
rtt.p_id,
isnull((select fio from person where p_id = rtt.p_id), '<неизвестно>') user_fio,
rtt.ogrn_date,
rtt.newpin,
rtt.status,
rtt.work_tm,
rtt.dost_tm,
iif(newpin is not null, iif(d.contrnum is null, rtt.dogovornum, d.contrnum), rtt.dogovornum) contrnum,
iif(newpin is not null, iif(d.contrdate is null, rtt.dogovordate, d.contrdate), rtt.dogovordate) contrdate,
case when rtt.bnk_code = -1 then
isnull((select BnK from dbo.banklist where Bnk = d.bank_id), -1) 
else rtt.bnk_code end bnk_code,
rtt.odz_buh,
isnull((select fio from dbo.person where p_id = rtt.odz_buh), '<нет данных>') odz_buh_fio,
rtt.depchiefsolve,
iif(df.shortfam = '', 0, 1) done,
--cc.savedate,
#r.savedate,
dp.DName
from ReqTorgT rtt
--left join (select pin, contrnum, contrdate, bank_id from defcontract where contrtip = 2 and actual = 1 and contrmain = 1) d on d.pin = rtt.newpin
left join (
	select defcontract.pin, contrnum, contrdate, bank_id, defcontract.our_id, fc.FirmGroup from defcontract 
    inner join FirmsConfig fc on fc.Our_id = defcontract.our_id
    where contrtip = 2 and contrmain = 1
) d on d.pin = rtt.newpin and (select FirmGroup from FirmsConfig where FirmsConfig.our_id = rtt.postav) = d.FirmGroup
--and d.our_id = rtt.postav
left join dbo.def df on df.pin = d.pin
--left join (select h.uid, h.savedate from Collectioner2.dbo.hdr h where ngrp in (58, 74, 155, 168, 183) group by h.uid, h.savedate) cc on cc.uid = rtt.newpin
left join #r on #r.nnak = rtt.newpin
inner join dbo.agentlist al on al.AG_ID = rtt.torgagent
inner join dbo.deps dp on dp.DepID = al.depid
where
rtt.nd between @nd1 and @nd2
and (case 
when (d.contrdate is null or rtrim(ltrim(d.contrdate)) = '') and (d.contrnum is null or rtrim(ltrim(d.contrnum)) = '') and rtt.newpin is not null then 0
when (d.contrdate is not null and rtrim(ltrim(d.contrdate)) <> '') and (d.contrnum is null or rtrim(ltrim(d.contrnum)) = '') then 1
when (d.contrdate is not null and rtrim(ltrim(d.contrdate)) <> '') and (d.contrnum is not null or rtrim(ltrim(d.contrnum)) <> '') then 2
when (d.contrdate is null or rtrim(ltrim(d.contrdate)) = '') and (d.contrnum is null or rtrim(ltrim(d.contrnum)) = '') and rtt.newpin is null then 3
end) in (@df1, @df2, @df3, @df4)
order by rtt.nd desc