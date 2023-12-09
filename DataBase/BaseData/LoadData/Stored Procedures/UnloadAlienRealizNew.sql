CREATE PROCEDURE [LoadData].UnloadAlienRealizNew @Our_ID int, @DateStart datetime, @DateEnd datetime, @AlienSale bit, @Sertif bit
AS
BEGIN

  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)

  if @AlienSale = 1 -- продажи товара выбранной организации через другие организации
  
  select v.hitag,n.ourid, sum(v.kol) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name, d.Obl_ID 
  from  nv v join nc n on v.datnom=n.datnom
             join visual s on v.tekid=s.id
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp     
             left join sertif f on s.sert_id=f.sert_id
             left join def d on n.b_id=d.pin
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on s.dck=dc.dck
  where ((n.datnom between @datnomStart and @datnomEnd and n.sp>0) or (n.refdatnom between @datnomStart and @datnomEnd and n.sp<0))
        and isnull(dc.our_id,7)=@Our_ID and n.ourid<>@Our_ID
        and g.MainParent not in (0,84,86,90) and (isnull(f.nVet,'')<>'' or @Sertif = 0) and d.worker=0 and n.Stip<>4
        and l.Discard=0
  group by n.ourid, v.hitag, e.name, d.Obl_ID 
  having sum(v.kol)<>0
  order by n.ourid, v.hitag
  
  else              --продажи чужого товара через выбранную организацию
  
  select n.nd,v.hitag, n.ourid, sum(v.kol) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name, d.Obl_ID 
  from  nv v join nc n on v.datnom=n.datnom
             join visual s on v.tekid=s.id
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on s.sert_id=f.sert_id  
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on s.dck=dc.dck
  where ((n.datnom between @datnomStart and @datnomEnd and n.sp>0) or (n.refdatnom between @datnomStart and @datnomEnd and n.sp<0))
        and isnull(dc.our_id,7)<>@Our_ID and n.ourid=@Our_ID
        and g.MainParent not in (0,84,86,90) and (isnull(f.nVet,'')<>'' or @Sertif = 0) and d.worker=0 and n.Stip<>4
        and l.Discard=0 
  group by  n.nd,n.ourid,v.hitag, e.name, d.Obl_ID 
  having sum(v.kol)<>0
  order by 1, n.ourid, v.hitag 
  
END