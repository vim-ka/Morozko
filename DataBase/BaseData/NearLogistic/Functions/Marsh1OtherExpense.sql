CREATE FUNCTION NearLogistic.Marsh1OtherExpense ( @mhid int
)
RETURNS money
AS
BEGIN
declare @smother money


 set @smother=((select 
         round(sum(0.104*(1+(c.extra/100))*(v.Price-v.Cost)*v.kol),2) -- OplTrud
         +round(sum(iif(isnull(d.weight,0)<>0, d.weight*v.kol, n.netto*v.kol)*g.Cost1kgStor*datediff(Day,d.datepost,c.nd)),2) -- PayStor
         +round(sum(iif(e.dfID=7, 0, 0.05*v.Cost*v.kol)),2) --для оптовых клиентов расход =0
         +round(sum(iif(isnull(d.weight,0)<>0, d.weight*v.kol, n.netto*v.kol)*g.Cost1kgDeliv),2) --PayLogBuy
  from nc c join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom
            join marsh m on c.mhid=m.mhid
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            left join visual d on v.tekid=d.id
            join def e on c.b_id=e.pin
  where m.mhid=@mhid)
/*  +isnull(
  (select    round(sum(0.104*(v.zakaz*v.price*(1+(c.extra/100))-v.zakaz*v.cost)*iif(n.flgweight=1,n.netto,1)),2) -- OplTrud
            +round(sum(n.netto*v.zakaz*g.Cost1kgStor*vi.MaxDiff),2) -- PayStor
            +round(sum(iif(e.dfID=7, 0, 0.05*v.Cost*iif(n.flgweight=1,n.netto,1))),2) --для оптовых клиентов расход =0
            +round(sum(n.netto*v.zakaz*g.Cost1kgDeliv),2) --PayLogBuy
  from nc c join nvzakaz v on v.datnom=c.datnom
            join marsh m on c.mhid=m.mhid
            join nomen n on v.hitag=n.hitag
            join GR g on n.ngrp=g.ngrp
            join def e on c.b_id=e.pin
            left join (select d.hitag, max(datediff(Day,d.datepost,dbo.today())) as MaxDiff
                       from visual d 
                       group by d.hitag) vi on vi.hitag=v.hitag
  where m.mhid=@mhid and v.done=0),0)*/
  )


Return isnull(@smother,0) 
END