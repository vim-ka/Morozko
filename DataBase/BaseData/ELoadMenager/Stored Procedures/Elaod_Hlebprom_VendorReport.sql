CREATE PROCEDURE ELoadMenager.Elaod_Hlebprom_VendorReport
@nd1 datetime,
@nd2 datetime
AS
begin                                      
declare @line varchar                                                               
declare @dck int
declare @ncod int 

declare @DCKncod varchar(20)
set @dckncod='64532;892'

if object_id('tempdb..#param') is not null drop table #param
create table #param (id int identity(1,1) not null,
                     param int)
insert into #param(param)
select value
from string_split(@DCKncod,';')
  
select @dck=param from #param where id=1
select @ncod=param from #param where id=2
  
set @line=''

select 	MONTH(c.ND) [Месяц],
		convert(varchar,c.nd,104) [Дата],
        ven.fam [Клиент],
        d.gpName [Юридическое лицо],
        iif(isnull(d.gpAddr,'')='','<нет данных>',d.gpAddr) [Адрес],
        isnull (nvv.ExtTag,'') [Код продукции],
        isnull(nom.name,'') [Номенклатура],
        '' [Продуктовая линия],
        '' [СТ НЗП],
        n.Kol  [Отгрузка в шт],
        (iif(nom.flgWeight=1, v.Weight*n.Kol,nom.netto*n.Kol)) [Отгрузка в кг], 
        (n.Price-(n.Price*(1.0*nom.nds/100))) [Отгрузка в продажных ценах без НДС],
        n.Price  [Отгрузка в продажных ценах с НДС],
        (n.Cost-(n.Cost*(1.0*nom.nds/100))) [Отгрузка в закупочных ценах без НДС],
        n.Cost [Отгрузка в закупочных ценах с НДС],
        0 [Возврат шт],
        0 [Возврат кг], 
        0 [Возврат в продажных ценах без НДС],
        0 [Возврат в продажных ценах с НДС],
        0 [Возврат в закупочных ценах без НДС],
        0 [Возврат в закупочных ценах с НДС],
        isnull(ap.Fio,'') [Торговый представитель],
        isnull(sp.Fio,'') [Супервайзер]
from dbo.nc c
join dbo.nv n with(nolock, index(nv_datnom_idx)) on c.DatNom = n.DatNom
join dbo.Visual v on n.TekID=v.id
join dbo.NomenVend nvv on v.hitag=nvv.Hitag and v.dck=nvv.dck
join dbo.def d on d.pin=c.b_id
join dbo.nomen nom on nom.hitag=n.hitag
join dbo.vendors ven on ven.ncod=nvv.ncod 
left join dbo.agentlist a on a.ag_id=c.ag_id
left join dbo.agentlist s on s.ag_id=a.sv_ag_id
left join dbo.person ap on ap.p_id=a.p_id
left join dbo.person sp on sp.p_id=s.p_id
where (c.ND >= @nd1)
       and (c.nd <=@nd2)
       and (n.Kol>0)
       and nvv.ncod=IIF(@dck=-1, @ncod, nvv.ncod)
       and nvv.dck = IIF(@dck=-1, nvv.DCK,@dck)

union all

select 	MONTH(c.ND) [Месяц],
		convert(varchar,c.nd,104) [Дата],
        ven.fam [Клиент],
        d.gpName [Юридическое лицо],
        iif(isnull(d.gpAddr,'')='','<нет данных>',d.gpAddr) [Адрес],
        isnull (nvv.ExtTag,'') [Код продукции],
         isnull(nom.name,'') [Номенклатура],
        '' [Продуктовая линия],
        '' [СТ НЗП],
        0 [Отгрузка в шт],
        0 [Отгрузка в кг],
        0 [Отгрузка в продажный ценах без НДС],
        0 [Отгрузка в продажных ценах с НДС],
        0 [Отгрузка в закупочных ценах без НДС],
        0 [Отгрузка в закупочных ценах с НДС],
        -n.Kol  [Возврат шт],
        -(iif(nom.flgWeight=1, v.Weight*n.Kol,nom.netto*n.Kol)) [Возврат кг], 
        (n.Price-(n.Price*(1.0*nom.nds/100))) [Возврат в продажных ценах без НДС],
        n.Price  [Возврат в продажных ценах с НДС],
        (n.Cost-(n.Cost*(1.0*nom.nds/100))) [Возврат в закупочных ценах без НДС],
        n.Cost [Возврат в закупочных ценах с НДС],
        ISNULL (ap.Fio,'') [Торговый представитель],
        Isnull (sp.Fio,'') [Супервайзер]
from dbo.nc c
join dbo.nv n with(nolock, index(nv_datnom_idx)) on c.DatNom = n.DatNom
join dbo.Visual v on n.TekID=v.id
join dbo.NomenVend nvv on v.hitag=nvv.Hitag and v.dck=nvv.dck
join dbo.def d on d.pin=c.b_id
join dbo.nomen nom on nom.hitag=n.hitag
join dbo.vendors ven on ven.ncod=nvv.ncod 
left join dbo.agentlist a on a.ag_id=c.ag_id
left join dbo.agentlist s on s.ag_id=a.sv_ag_id
left join dbo.person ap on ap.p_id=a.p_id
left join dbo.person sp on sp.p_id=s.p_id
where (c.ND >= @nd1)
       and (c.nd <=@nd2)
       and (n.Kol<0)
       and nvv.ncod=IIF(@dck=-1, @ncod, nvv.ncod)
       and nvv.dck = IIF(@dck=-1, nvv.DCK,@dck)

if object_id('tempdb..#param') is not null drop table #param
end