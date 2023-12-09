CREATE function RetroB.BasCheckPrice_new (@ncom int)
returns @res table (hitag int, prihodcost decimal(15,4), ncod int, dck int, nd datetime, tekid int, cost1kg decimal(15,4),
									  flgweight bit, prid int, basecost decimal(15,4) )
as
begin  
  insert into @res
  select x.*,
         retrob.getbaspriceid(x.hitag,x.ncod,x.dck,x.cost,x.cost1kg,x.nd) [prid],
         0

  from (
  select 	i.hitag, i.cost, dc.Ncod, c.dck, dateadd(day, datediff(day, 0, c.date),0)  [nd],
          isnull(i.id,0) [tekid], iif(i.weight = 0,0,round(i.cost/i.weight, 5)) [cost1kg],
          iif(i.weight > 0, 1, 0) [flgweight]         
  from morozdata.dbo.comman c
  join morozdata.dbo.inpdet i on i.ncom=c.ncom
  join morozdata.dbo.defcontract dc on dc.dck=c.dck
  where c.ncom=@ncom) x
  
  update a set a.basecost=p.basecost
  from @res a
  join retrob.basprices p on p.prid=a.prid
  
  return 
end