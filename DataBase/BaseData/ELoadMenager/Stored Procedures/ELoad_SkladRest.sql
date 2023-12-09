CREATE PROCEDURE ELoadMenager.ELoad_SkladRest
@sklad varchar(1000)
AS
BEGIN
if object_id('tempdb..[#sklad]') is not null drop table [#sklad]
create table [#sklad] (sklad int)

insert into [#sklad] 
select si.number
from String_to_Int(@sklad,',',1) si

create nonclustered index idx_sklad on [#sklad](sklad)

select v.sklad [sklad],
			 v.hitag [hitag],
       n.[name] [name],
       u.fio [catfio],
       isnull(e.fam,'<..>') [vendor],
       n.netto,
       sum(v.morn-v.sell+v.isprav-v.remov) [rest],
       sum((v.morn-v.sell+v.isprav-v.remov)*iif(n.flgWeight=1,v.weight,n.netto)) [restKG],
       sum(iif(n.flgweight=1,iif((v.morn-v.sell+v.isprav-v.remov)*iif(n.flgWeight=1,v.weight,n.netto)=0,0,v.cost),v.cost*(v.morn-v.sell+v.isprav-v.remov))) [sCost], 
       sum(iif(n.flgweight=1,iif((v.morn-v.sell+v.isprav-v.remov)*iif(n.flgWeight=1,v.weight,n.netto)=0,0,v.price),v.price*(v.morn-v.sell+v.isprav-v.remov))) [sPrice]
into [#res]
from tdvi v 
inner join [#sklad] on [#sklad].sklad=v.sklad
inner join nomen n on n.hitag=v.hitag
left join vendors e on v.ncod=e.ncod
left join usrPwd u on e.cat_uin=u.uin
--where v.morn-v.sell+v.isprav-v.remov>0
group by v.sklad,v.hitag,n.[name], u.fio, isnull(e.fam,'<..>'), n.netto

select sklad [Склад],
			 hitag [КодТовара],
       [name] [Наименование],
       [netto] [СреднийВес],
       rest [ОстатокШТ],
       restKG [ОстатокКГ],
       isnull(catfio,'<не задан>') [Категорийный менеджер],
       vendor [Поставщик],
       iif(restkg=0,0,cast((sCost / restKG)*netto as decimal(10,2))) [ЦенаПриходШТ],
       iif(restkg=0,0,cast(sCost / restKG as decimal(10,2))) [ЦенаПриходКГ],
       cast(sCost as decimal(10,2)) [СуммаПрихода],
       iif(restkg=0,0,cast((sPrice / restKG)*netto as decimal(10,2))) [ЦенаПродажиШТ],
       iif(restkg=0,0,cast(sPrice / restKG as decimal(10,2))) [ЦенаПродажиКГ],
       cast(sPrice as decimal(10,2)) [СуммаПродажи]
from [#res]
order by catfio, vendor,sklad,name

drop table [#sklad]
drop table [#res]
END