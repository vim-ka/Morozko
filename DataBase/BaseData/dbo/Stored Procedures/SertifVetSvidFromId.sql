CREATE PROCEDURE dbo.SertifVetSvidFromId @Our_ID_Owner INT, @Our_ID_Saler INT, @DateStart DATETIME, @DateEnd DATETIME, @hitag INT, @Id INT
AS 
BEGIN
  DECLARE @datnomStart int, @datnomEnd INT, @dt datetime
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  SET @dt = dbo.today()

  select DISTINCT SertifVetSvid.Id_vet_svid
              --ISNULL(s.startid, 0) Id, 
              --InpdetVetSvid.IDIVS,              
              --SertifVetSvid.N_vet_svid, 
              --SertifVetSvid.Date_vet_svid
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck
             left join InpdetVetSvid ON s.startid = InpdetVetSvid.Id
             left join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner
         
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        AND v.hitag = @hitag AND s.startid = @Id
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0

UNION
  select DISTINCT SertifVetSvid.Id_vet_svid
              --ISNULL(s.startid, 0) Id, 
              --InpdetVetSvid.IDIVS,              
              --SertifVetSvid.N_vet_svid, 
              --SertifVetSvid.Date_vet_svid
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join visual si on v.tekid=si.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck
             left join InpdetVetSvid ON si.startid = InpdetVetSvid.Id
             left join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner
         
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        AND v.hitag = @hitag AND si.startid = @Id
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0

END