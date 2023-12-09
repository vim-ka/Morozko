CREATE procedure ELoadMenager.eload_shipping_period_sklad
@nd1 datetime,
@nd2 datetime,
@sklad int
as
begin
  select c.nd [дата], c.datnom%10000 [накладная], c.b_id [код клиента], c.fam [клиент], n.hitag [код товара], 
  			 n.name [наименование], iif(n.flgweight=0,' шт',' кг') [единицы измерения], v.kol * iif(n.flgweight=0,1,isnull(t.weight,s.weight)) [количество],
         v.kol * v.price [сумма продажи], v.kol * v.cost [сумма закупки] 
  from dbo.nc c 
  join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
  join dbo.nomen n on n.hitag=v.hitag
  left join dbo.tdvi t on t.id=v.tekid
  left join dbo.visual s on s.id=v.tekid
  where c.nd between @nd1 and @nd2
        and v.sklad=@sklad and v.kol>0
end