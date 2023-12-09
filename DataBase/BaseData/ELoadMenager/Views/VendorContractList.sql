CREATE VIEW ELoadMenager.VendorContractList
AS
  with vendors_contract as (
  select dc.dck [id],
         iif(dc.actual=0,'[Закрыт] ','')+dc.contrname [list],
         d.ncod
  from dbo.defcontract dc
  join dbo.def d on d.pin=dc.pin 
  where d.ncod in ( select v.ncod from dbo.vendors v)
        and dc.contrtip=1
  union
  select dc.dck [id],
         iif(dc.actual=0,'[Закрыт] ','')+dc.contrname [list],
         dc.pin
  from dbo.defcontract dc 
  where dc.pin in ( select v.ncod from dbo.vendors v)
        and dc.contrtip=1)
  select top 5000
  			 cast(x.[id] as varchar)+';'+cast(x.[ncod] as varchar) [id],
         v.[fam]+', '+x.[list]+' {'+cast(x.[id] as varchar)+';'+cast(x.[ncod] as varchar)+'}' [list]
         --x.[list]+', '+cast(x.[ncod] as varchar)+'::'+v.fam [list]
  from (      
  select [id],[list],[ncod] from vendors_contract 
  union all 
  select -1,'Все договора', ncod
  from (select ncod from vendors_contract group by ncod having count(id)>1) a
  ) x
  join dbo.vendors v on v.ncod=x.ncod
  order by x.[ncod],x.[id]