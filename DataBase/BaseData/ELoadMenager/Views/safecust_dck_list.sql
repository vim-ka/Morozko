CREATE VIEW ELoadMenager.safecust_dck_list
AS
select top 9999 dc.dck [id], cast(d.pin as nvarchar)+'#'+d.brname+'('+cast(dc.dck as nvarchar)+')' [list]
from dbo.defcontract dc
join dbo.def d on d.pin=dc.pin
where dc.contrtip=5
order by d.brname