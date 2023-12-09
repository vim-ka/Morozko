CREATE PROCEDURE LoadData.UnloadAlienRealizToday @Our_ID int, @DateStart datetime, @DateEnd datetime, @AlienSale bit, @Sertif bit
AS
BEGIN

  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  
  --if object_id('tempdb..#ncods') is not null drop table #ncods
  declare @ncod varchar(max)
  set @ncod='551,1420,1372,1630,1334,1480,1670,1312,188,1064,1595,1602,1471,1289,1596,1659,844,1300,153,939,254,1236,'+
  					'521,1664,1473,1413,906,1186,1430,1161,390,1652,1171,1677,1658,1298,1599,939,758,670,'+
            '694,1527,1589,1542,1495,1574,1681,1597,758,938,1642,1524,1564,833,1582,1549,1531,1545,1566,1652,1525,1536,1568,1604,670,1663,728,1521,1377,1375,'+
            '1506,1635,1693,1692,1490,1705,1649,1729'
  --create table #ncods (ncod int)
	--insert into #ncods
  --select s.number
  --from dbo.String_to_Int(@ncod,',',1) s

  if @AlienSale = 1 -- продажи товара выбранной организации через другие организации
  
  select v.hitag,n.ourid, sum(iif(e.flgWeight=1,s.weight,v.kol)) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name+', '+isnull(ve.fam,'') [name], d.Obl_ID
  			 --,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName 
  from  nc n join nv v on n.datnom=v.datnom
             left join tdvi s on v.tekid=s.id
             left join vendors ve on ve.ncod=s.ncod
             left join Producer pr on pr.ProducerID=s.ProducerID
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp     
             left join sertif f on s.sert_id=f.sert_id
             left join def d on n.b_id=d.pin
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on s.dck=dc.dck
  where n.datnom between @datnomStart and @datnomEnd and isnull(dc.our_id,7)=@Our_ID and n.ourid<>@Our_ID
        and g.MainParent not in (0,84,86,90) and /*(isnull(f.nVet,'')<>'' or @Sertif = 0) and*/ d.worker=0 and n.Stip<>4
        and l.Discard=0 
        --and (isnull(g.Vet,0)=1 or @Sertif = 0)
        and (@Sertif=0 or ve.ncod in (select s.number from dbo.String_to_Int(@ncod,',',1) s))
  group by n.ourid, v.hitag, e.name, d.Obl_ID,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName
  having sum(v.kol)<>0
  
  union
  
  select v.hitag,n.ourid, 
         sum(v.zakaz) as kol, 
         sum(v.zakaz*e.cost) as sp,
         sum(v.zakaz*e.price*(1.0+n.extra/100)) as sl,
         e.name+', '+isnull(ve.fam,'') [name], d.Obl_ID
  			 --,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName  
  from  nc n join nvzakaz v on n.datnom=v.datnom and v.done=0
             left join nomen e on v.hitag=e.hitag
             left join (select tdvi.hitag,max(tdvi.ncod) ncod from tdvi group by tdvi.hitag) s on v.hitag=s.hitag
             left join vendors ve on ve.ncod=s.ncod
             left join Producer pr on pr.ProducerID=e.LastProducerID
             left join gr g on e.ngrp=g.ngrp     
             left join def d on n.b_id=d.pin
             join FirmsConfig f on f.our_id=n.ourid
  where n.datnom between @datnomStart and @datnomEnd and n.ourid not in (10,7) and f.firmgroup=@our_id
        and g.MainParent not in (0,84,86,90) and d.worker=0 and n.Stip<>4
        --and (isnull(g.Vet,0)=1 or @Sertif = 0)
        and (@Sertif=0 or ve.ncod in (select s.number from dbo.String_to_Int(@ncod,',',1) s))
  group by n.ourid, v.hitag, e.name, d.Obl_ID,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName
  having sum(v.zakaz)<>0
  
  order by n.ourid, v.hitag
  
  else              --продажи чужого товара через выбранную организацию
  
  select n.nd,v.hitag, n.ourid, sum(v.kol) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name+', '+isnull(ve.fam,'') [name], d.Obl_ID
  			 --,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName 
  from  nv v join nc n on v.datnom=n.datnom
             join tdvi s on v.tekid=s.id
             left join vendors ve on ve.ncod=s.ncod
             left join Producer pr on pr.ProducerID=s.ProducerID
             left join nomen e on v.hitag=e.hitag
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on s.sert_id=f.sert_id  
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on s.dck=dc.dck
  where n.datnom between @datnomStart and @datnomEnd and isnull(dc.our_id,7)<>@Our_ID and n.ourid=@Our_ID
        and g.MainParent not in (0,84,86,90) and /*(isnull(f.nVet,'')<>'' or @Sertif = 0) and*/ d.worker=0 and n.Stip<>4
        and l.Discard=0 
        --and (isnull(g.Vet,0)=1 or @Sertif = 0)
        and (@Sertif=0 or ve.ncod in (select s.number from dbo.String_to_Int(@ncod,',',1) s))
  group by  n.nd,n.ourid,v.hitag, e.name, d.Obl_ID,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName
  having sum(v.kol)<>0
  
  union
  
  select n.nd, v.hitag,n.ourid, sum(v.zakaz) as kol, sum(v.zakaz*e.cost) as sp, sum(v.zakaz*e.price*(1.0+n.extra/100)) as sl, e.name+', '+isnull(ve.fam,'') [name], d.Obl_ID 
  			 --,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName 
  from  nc n join nvzakaz v on n.datnom=v.datnom and v.done=0
             left join nomen e on v.hitag=e.hitag
             left join (select tdvi.hitag,max(tdvi.ncod) ncod from tdvi group by tdvi.hitag) s on v.hitag=s.hitag
             left join vendors ve on ve.ncod=s.ncod
             left join Producer pr on pr.ProducerID=e.LastProducerID
             left join gr g on e.ngrp=g.ngrp     
             left join def d on n.b_id=d.pin
  where n.datnom between @datnomStart and @datnomEnd and n.ourid not in (10,7)
        and g.MainParent not in (0,84,86,90) and d.worker=0 and n.Stip<>4
        --and (isnull(g.Vet,0)=1 or @Sertif = 0)
        and (@Sertif=0 or ve.ncod in (select s.number from dbo.String_to_Int(@ncod,',',1) s))
  group by n.nd,n.ourid, v.hitag, e.name, d.Obl_ID,ve.ncod,ve.fam,pr.ProducerID,pr.ProducerName
  having sum(v.zakaz)<>0
  
  order by 1, n.ourid, v.hitag 
  --drop table #ncods
END