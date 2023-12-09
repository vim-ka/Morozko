CREATE procedure warehouse.terminal_GetBackList
@retid int
as
begin
	select row_number() over(order by n.hitag) * 1000 [id],
  			 row_number() over(order by n.hitag) * 1000 [parent_id],
  			 0 [sklad],
         d.reqretid,
         n.hitag,
         n.name+',('+cast(n.hitag as varchar)+')' [name],
         iif(a.depid=3,'[СЕТЬ] ','')+iif(n.flgWeight=1,'[В]','[Ш]')+'['+cast(n.netto as varchar)+'кг]'+'['+isnull(n.barcode,'<..>')+']' [descr],
         iif(n.flgWeight=1,1,sum(d.kol)) [zakaz_kol],       
         sum(d.fact_weight) [zakaz_weight],
         0 [inKol],
         cast(0.0 as decimal(15,4)) [inWeight],
         n.flgWeight,
         n.barcode,
         isnull(f.gpname,f.brname) [bName],
         cast(0 as bit) [done],
         cast(0 as bit) [sklchk],
         max(d.id) [RowID]
  from dbo.reqreturndet d
  join dbo.reqreturn r on r.reqnum=d.reqretid
  join dbo.def f on f.pin=r.pin
  join dbo.nomen n on d.hitag=n.hitag
  join dbo.defcontract dc on dc.dck=r.dck
  join dbo.agentlist a on a.ag_id=dc.ag_id
  where d.reqretid= @retid
  			and d.done=0
  group by d.reqretid,n.hitag,n.name+',('+cast(n.hitag as varchar)+')',iif(a.depid=3,'[СЕТЬ] ','')+iif(n.flgWeight=1,'[В]','[Ш]')+'['+cast(n.netto as varchar)+'кг]'+'['+isnull(n.barcode,'<..>')+']',
           n.flgWeight,n.barcode,isnull(f.gpname,f.brname), a.depid
end