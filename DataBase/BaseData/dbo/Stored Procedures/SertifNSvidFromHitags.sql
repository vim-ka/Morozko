CREATE PROCEDURE dbo.SertifNSvidFromHitags @Our_ID_Owner INT, @Our_ID_Saler INT, @DateStart DATETIME, @DateEnd DATETIME, @HitagStr varchar(8000)
AS 
BEGIN
  DECLARE @datnomStart int, @datnomEnd INT, @datnomStartSvid INT, @dt datetime
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  set @datnomStartSvid = dbo.InDatNom(0,DATEADD(month, -1,@DateStart)) 
  SET @dt = dbo.today()


if object_id('tempdb..#HitagList') is not null drop table #HitagList
create table #HitagList (hitag int)
--заполняем Hitag'и
  insert into #HitagList (hitag) 
  select K as hitag from dbo.Str2intarray(@HitagStr)


--заполняем Id'ы
if object_id('tempdb..#IDList') is not null drop table #IDList
create table #IDList (ID int)
  insert into #IDList (ID) 
 select DISTINCT ISNULL(s.startid, 0) Id
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck 
             JOIN #HitagList ON v.Hitag = #HitagList.hitag      
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        --AND v.hitag IN (SELECT DISTINCT #HitagList.hitag FROM #HitagList)
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd = @dt --?

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
             JOIN #HitagList ON v.Hitag = #HitagList.hitag         
  where n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        --AND v.hitag IN (SELECT DISTINCT #HitagList.hitag FROM #HitagList)
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd<>@dt --?


--выбираем вет. св-ва
  select DISTINCT s.startid Id, SertifVetSvid.Id_vet_svid
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck
              join InpdetVetSvid ON s.startid = InpdetVetSvid.Id
              join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner
              JOIN #IDList ON #IDList.ID = s.STARTID
  where n.datnom BETWEEN @datnomStartSvid and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        --AND s.startid IN (SELECT DISTINCT #IDList.ID FROM #IDList)      
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd = @dt --?
UNION
  select DISTINCT si.startid Id, SertifVetSvid.Id_vet_svid
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join visual si on v.tekid=si.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck
              join InpdetVetSvid ON si.startid = InpdetVetSvid.Id
              join SertifVetSvid ON InpdetVetSvid.VetId = SertifVetSvid.Id_vet_svid AND SertifVetSvid.Is_Del = 0 AND SertifVetSvid.Our_id = @Our_ID_Owner
              JOIN #IDList ON #IDList.ID = si.STARTID
  where n.datnom between @datnomStartSvid and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler
        --AND si.startid IN (SELECT DISTINCT #IDList.ID FROM #IDList)
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>0
        and n.nd <> @dt --?
drop table #HitagList
drop table #IDList
END