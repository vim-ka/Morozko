CREATE procedure dbo.comman_print_mx
@ncom int
as
begin
  select fc.ourname+','+fc.ouraddr+','+fc.phone [save_org],
         fc.okpo [save_okpo],
         isnull(d.brname,'')+','+isnull(d.braddr,'')+','+isnull(d.brphone,'') [owner_org],
         isnull(d.okdp,'') [owner_okdp],
         isnull(d.okpo,'') [owner_okpo],
         dc.dck [owner_contract],
         convert(varchar,dc.contrdate,104) [owner_contract_date],
         c.ncom [form_num],
         convert(varchar,c.date,104) [form_date],
         'продукты питания' [form_name],
         n.name [nomen_name],
         n.hitag [nomen_code],
         --iif(n.flgweight=1,'кг','шт') [nomen_unit],
         units.UnitName AS nomen_unit,
         --iif(n.flgweight=1,166,796) [nomen_unit_code],
         CAST(units.OKEI AS INT) AS nomen_unit_code,
         --iif(n.flgweight=1,i.kol*isnull(t.weight,s.weight),i.kol) [nomen_count],
         i.QTY AS nomen_count, 
         --iif(n.flgweight=1,round(i.summacost/isnull(t.weight,s.weight),4),i.price) [nomen_price],
         i.price AS nomen_price,
         --i.price*iif(n.flgweight=1,1,i.kol) [nomen_sumprice],
         i.summacost [nomen_sumprice],
         '' [takken_staff], 
         --'Власов Д.Д. (по доверенности №1 от 07.02.18г.)' 
         '' [takken_fio],
         '' [given_staff],
         --'Боровиков А.В.' 
         '' [given_fio]
  from dbo.comman c 
  join dbo.defcontract dc on dc.dck=c.dck
  join dbo.firmsconfig fc on fc.our_id=dc.our_id
  join dbo.def d on d.pin = dc.pin    --iif(dc.contrtip in (5,6),d.pin,d.ncod)=dc.pin
  join dbo.inpdet i on i.ncom=c.ncom 
  join dbo.nomen n on n.hitag=i.hitag
  left join dbo.tdvi t on t.id=i.id
  left join dbo.visual s on s.id=i.id
  LEFT JOIN units ON i.unid = units.UnID
  where c.ncom = @ncom
end