CREATE PROCEDURE [dbo].FinAlienRealiz @Our_ID int, @DateStart datetime, @DateEnd datetime, @AlienSale smallint
AS
BEGIN

  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)

  if @AlienSale = 1 -- продажи товара выбранной организации через другие организации
  
  select n.ourid,
         iif(n.ourid=7 and a.DepID=3,fc.ourname+'(Сети)',fc.ourname) as ourname,
         year(n.nd) as yr, 
         month(n.nd) as mth, 
         sum(v.kol*v.cost) as sc,
         sum(v.kol*v.price*(1.0+n.extra/100)) as sp,
         sum(v.kol*v.price*(1.0+n.extra/100))-sum(v.kol*v.cost) as nac,
         e.nds
  from  nv v join nc n on v.datnom=n.datnom
             join visual s on v.tekid=s.id
             left join comman c on s.ncom=c.ncom
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp     
             left join def d on n.b_id=d.pin
             left join skladlist l on v.sklad=l.skladno
             left join firmsconfig fc on fc.our_id=n.ourid
             left join defcontract dc on n.dck=dc.dck
             left join agentlist a on dc.ag_id=a.ag_id
  where n.datnom between @datnomStart and @datnomEnd and isnull(c.our_id,@Our_ID)=@Our_ID --and n.ourid<>@Our_ID
        and g.AgInvis=0 and n.Stip<>4 --and d.worker=0
        and l.Discard=0
  group by n.ourid, iif(n.ourid=7 and a.DepID=3,fc.ourname+'(Сети)',fc.ourname), e.nds, year(n.nd), month(n.nd)
  having sum(v.kol)<>0
  order by yr, mth,n.ourid, nds
  
  else              --продажи чужого товара через выбранную организацию
  
  select n.nd,v.hitag, n.ourid, sum(v.kol) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name
  from  nv v join nc n on v.datnom=n.datnom
             join visual s on v.tekid=s.id
             left join comman c on s.ncom=c.ncom   
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on s.sert_id=f.sert_id  
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
  where n.datnom between @datnomStart and @datnomEnd and isnull(c.our_id,@Our_ID)<>@Our_ID and n.ourid=@Our_ID
        and g.AgInvis=0 and n.Stip<>4 --and d.worker=0
        and l.Discard=0 
  group by  n.nd,n.ourid,v.hitag, e.name
  having sum(v.kol)<>0
  order by 1, n.ourid, v.hitag 
  
END