CREATE PROCEDURE dbo.SertifUnloadAlienRealiz @Our_ID_Owner int, @Our_ID_Saler int, @DateStart datetime, @DateEnd datetime
AS --НОВАЯ ПРОЦЕДУРА ДЛЯ ПЕРЕМЕЩЕНИЙ
BEGIN

declare @datnomStart bigint, @datnomEnd bigint, @dt datetime

  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  SET @dt = dbo.today()
              --продажи чужого товара через выбранную организацию
  
  SELECT TEMP.ND, TEMP.OurID, TEMP.Hitag, SUM(TEMP.kol) AS kol,
         SUM(TEMP.sp) AS sp, SUM(TEMP.sl) AS sl, TEMP.Name, 
         MAX(TEMP.Id) AS Id, 
         --MAX(TEMP.N_vet_svid) AS N_vet_svid, 
          (SELECT MAX(svs.N_vet_svid) 
            FROM InpdetVetSvid ivs 
            JOIN SertifVetSvid svs ON ivs.VetId = svs.Id_vet_svid AND svs.Is_Del = 0 AND svs.Our_id = @Our_ID_Owner
            WHERE ivs.id = MAX(TEMP.Id)) AS N_vet_svid,
         MAX(TEMP.sert_id) AS sert_id, TEMP.NameCat,
    ------------------------------------------------
         row_number() over (order by temp.name asc) as rank,
         temp.Nom, temp.OKEI, temp.nds,
         SUM(temp.Kol2) AS Kol2, SUM(temp.Brutto) AS Brutto, SUM(temp.Netto) as Netto, AVG(temp.PRICE) AS PRICE,
         SUM(temp.NDSsum) AS NDSsum, SUM(temp.SumWithOutNDS) AS SumWithOutNDS, SUM(temp.SumWithNDS) AS SumWithNDS
  FROM
  (
   select n.nd, n.ourid, 
         v.hitag, v.kol as kol, v.kol*v.cost as sp, v.kol*v.price*(1.0+n.extra/100) as sl, 
         e.name as [name],  
         s.startid Id, 
         SertifVetSvid.N_vet_svid, 
         f.sert_id, 
         SertifVetCat.NameCat,
--------------------------------------------------------------------------------------------------------------------------
         CASE WHEN e.flgWeight = 1 THEN 'кг' ELSE 'шт' END Nom,
         CASE WHEN e.flgWeight = 1 THEN '166' ELSE '796' END OKEI,
         (iif(e.flgWeight=1, s.weight, e.Netto)/e.minp) AS Kol2,
         iif(e.flgWeight=1, s.weight, e.Brutto) as Brutto, 
         iif(e.flgWeight=1, s.weight, e.Netto) as Netto,
         (s.PRICE-(s.PRICE*(e.nds)/100)) AS PRICE, e.nds,
         (((s.PRICE-s.PRICE*e.nds/100)*iif(e.flgWeight=1, s.weight, e.Netto))*e.nds/100) AS NDSsum,
         ((s.PRICE-s.PRICE*e.nds/100)*iif(e.flgWeight=1, s.weight, e.Netto)) AS SumWithOutNDS,
         (s.price)*iif(e.flgWeight=1, s.weight, e.Netto) AS SumWithNDS

  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             --left join visual si on v.tekid=si.id
             left join vendors ve on ve.ncod = s.ncod
             left join Producer pr on pr.ProducerID=s.ProducerID
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on f.sert_id = s.sert_id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck
             left join InpdetVetSvid ON s.startid = InpdetVetSvid.Id AND InpdetVetSvid.OurID = @Our_ID_Owner
             left join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner 
                  
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler 
        --and g.MainParent not in (0,84,86,90) 
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd=@dt
        AND SertifVetSvid.Our_id = @Our_ID_Owner
UNION --all

select n.nd, n.ourid, 
         v.hitag, v.kol as kol, v.kol*v.cost as sp, v.kol*v.price*(1.0+n.extra/100) as sl, 
         e.name as [name],  
         ISNULL(si.startid, 0) Id, 
         SertifVetSvid.N_vet_svid, 
         f.sert_id, 
         SertifVetCat.NameCat,
--------------------------------------------------------------------------------------------------------------------------
         CASE WHEN e.flgWeight = 1 THEN 'кг' ELSE 'шт' END Nom,
         CASE WHEN e.flgWeight = 1 THEN '166' ELSE '796' END OKEI,
         (iif(e.flgWeight=1, si.weight, e.Netto)/e.minp) AS Kol2,
         iif(e.flgWeight=1,si.weight, e.Brutto) as Brutto, 
         iif(e.flgWeight=1, si.weight, e.Netto) as Netto,
         (si.PRICE-(si.PRICE*(e.nds)/100)) AS PRICE, e.nds,
         (((si.PRICE-si.PRICE*e.nds/100)*iif(e.flgWeight=1, si.weight, e.Netto))*e.nds/100) AS NDSsum,
         ((si.PRICE-si.PRICE*e.nds/100)*iif(e.flgWeight=1, si.weight, e.Netto)) AS SumWithOutNDS,
         (si.price)*iif(e.flgWeight=1, si.weight, e.Netto) AS SumWithNDS

  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             --left join tdvi s on v.tekid=s.id
             left join visual si on v.tekid=si.id
             left join vendors ve on ve.ncod = si.ncod --s.ncod
             left join Producer pr on pr.ProducerID= si.ProducerID--s.ProducerID
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on f.sert_id = si.sert_id --s.sert_id=f.sert_id  
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck --s.dck=dc.dck
             left join InpdetVetSvid ON si.startid = InpdetVetSvid.Id AND InpdetVetSvid.OurID = @Our_ID_Owner
             left join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner --n.OurID 
                  
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler 
        --and g.MainParent not in (0,84,86,90) 
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd<>@dt
        AND SertifVetSvid.Our_id = @Our_ID_Owner


  --group by  n.nd, n.ourid, v.hitag, e.flgWeight,e.name, Inpdet.Id, SertifVetSvid.N_vet_svid, Inpdet.sert_id, SertifVetCat.NameCat,
------------------------------------------------------------------------------------------
            --e.Netto, e.Brutto, s.price, e.nds, e.flgWeight, e.minp
 
 -- having sum(v.kol)<>0
) TEMP
GROUP BY TEMP.nd, TEMP.OurID, TEMP.Hitag, TEMP.name, TEMP.NameCat,
------------------------------------------------------------------------------------------
         temp.Nom, temp.OKEI, temp.nds  

ORDER BY TEMP.name asc 

END