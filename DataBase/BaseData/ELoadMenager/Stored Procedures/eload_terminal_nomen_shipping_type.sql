create procedure ELoadMenager.eload_terminal_nomen_shipping_type
as 
begin
select distinct n.hitag [код товара], n.name [наименование], 
			 substring(l.msg,8,charindex(']',l.msg,7)-8) [способ набора]
from warehouse.terminal_shippingzakaz_log l
join dbo.nvzakaz z on z.nzid=l.nzid
join dbo.nomen n on n.hitag=z.hitag
where z.id>0 and charindex(']',l.msg,7)>8
			and patindex('%неизв%',l.msg)=0
      and patindex('%-1%',l.msg)=0
order by 2,3
end