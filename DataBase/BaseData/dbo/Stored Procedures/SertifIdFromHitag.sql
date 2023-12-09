CREATE PROCEDURE dbo.SertifIdFromHitag @Our_ID_Owner2 int, @Our_ID_Saler2 int, @DateStart2 datetime, @DateEnd2 DATETIME, @hitag2 INT
AS 
BEGIN
  declare @datnomStart int, @datnomEnd INT, @dt datetime

  set @datnomStart = dbo.InDatNom(0,@DateStart2)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd2)
  SET @dt = dbo.today()
              --продажи чужого товара через выбранную организацию

 select DISTINCT ISNULL(s.startid, 0) Id
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck 
                   
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner2 and n.ourid=@Our_ID_Saler2 
        AND v.hitag = @hitag2
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        --and n.nd = @dt --?

UNION 

select DISTINCT ISNULL(si.startid, 0) Id
  from  nv v 
  join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join visual si on v.tekid=si.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck 
                   
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner2 and n.ourid=@Our_ID_Saler2 
        AND v.hitag = @hitag2
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        --and n.nd<>@dt --?

END