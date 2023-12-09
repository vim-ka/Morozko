CREATE procedure FillNomenPrice
as
BEGIN 
	INSERT into tmpUpdateNomen(dt) select getdate()
  /*create table #T (hitag int, LDP datetime, LPrice money, LCost decimal(12,5))

  insert into #T
  select T.Hitag, E.LDP, max(T.Price) as LPrice, max(T.Cost) as LCost
   from tdvi t inner join (select tdVi.hitag, max(tdvi.DATEPOST) as LDP 
      from tdvi group by tdVi.hitag) E on E.Hitag=T.Hitag and T.DATEPOST=E.LDP
   group by T.Hitag, E.LDP
   
   
  update nomen set Price=(select LPrice from #T where #T.hitag=nomen.hitag) 
  where hitag in (select hitag from #t)

  update nomen set Cost=(select LCost from #T where #T.hitag=nomen.hitag) 
  where hitag in (select hitag from #t)
  
  update nomen set price=(select max(round(i.price/iif(i.weight=0,1,i.weight),2)) from inpdet i where i.hitag=nomen.hitag
                        and i.ncom=(select max(n.ncom) from inpdet n where n.hitag=nomen.hitag))
  where flgWeight=1
  update nomen set cost=(select max(round(i.cost/iif(i.weight=0,1,i.weight),2)) from inpdet i where i.hitag=nomen.hitag
                        and i.ncom=(select max(n.ncom) from inpdet n where n.hitag=nomen.hitag))
  where flgWeight=1

  drop table #T*/
	
	
END