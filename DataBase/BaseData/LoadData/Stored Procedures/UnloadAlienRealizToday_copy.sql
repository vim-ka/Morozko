CREATE PROCEDURE LoadData.UnloadAlienRealizToday_copy @Our_ID_Owner int, @Our_ID_Saler int, @DateStart datetime, @DateEnd DATETIME
AS
BEGIN

  declare @datnomStart int, @datnomEnd INT, @dt datetime
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  SET @dt = dbo.today()
              --продажи чужого товара через выбранную организацию
  
  SELECT TEMP.ND, TEMP.OurID, TEMP.Hitag, SUM(TEMP.kol) AS kol,
         SUM(TEMP.sp) AS sp, SUM(TEMP.sl) AS sl, TEMP.Name, 
         MAX(TEMP.Obl_ID) AS obl_ID, 
         MAX(TEMP.inId) AS inId, 
         MAX(TEMP.N_vet_svid) AS N_vet_svid, 
         MAX(TEMP.sert_id) AS sert_id, TEMP.NameCat
  FROM
  (
  select n.nd, n.ourid, v.hitag, sum(v.kol) as kol, sum(v.kol*v.cost) as sp, sum(v.kol*v.price*(1.0+n.extra/100)) as sl, e.name as [name], d.Obl_ID, ISNULL(Inpdet.inId,0) inId, SertifVetSvid.N_vet_svid, Inpdet.sert_id, SertifVetCat.NameCat
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             join SertifGr ON e.ngrp = SertifGr.Ngrp
             join SertifVetCat ON SertifGr.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join visual si on v.tekid=si.id
             left join vendors ve on ve.ncod = IIF(n.nd=@dt, s.ncod, si.ncod) --s.ncod
             left join Producer pr on pr.ProducerID=IIF(n.nd=@dt,s.ProducerID, si.ProducerID) --s.ProducerID
             left join gr g on e.ngrp=g.ngrp
             left join sertif f on f.sert_id = IIF(n.nd=@dt, s.sert_id, si.sert_id) --s.sert_id=f.sert_id  
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = IIF(n.nd=@dt, s.dck, si.dck) --s.dck=dc.dck
             left join Inpdet ON  Inpdet.id = iif(n.nd=@dt, s.startid, si.startid)
             left join InpdetVetSvid ON Inpdet.inId = InpdetVetSvid.inId
             left join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Our_id = n.OurID AND SertifVetSvid.Is_Del = 0
                  
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler 
        and g.MainParent not in (0,84,86,90) and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0 
  group by  n.nd, n.ourid, v.hitag, e.name, d.Obl_ID, Inpdet.inId, SertifVetSvid.N_vet_svid, Inpdet.sert_id, SertifVetCat.NameCat
  having sum(v.kol)<>0
) TEMP
GROUP BY TEMP.nd, TEMP.OurID, TEMP.Hitag, TEMP.name, TEMP.NameCat
      
ORDER BY TEMP.name asc 

END