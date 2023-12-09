CREATE PROCEDURE dbo.SertifNCMove @datnom INT --1706211144
AS
--перемещение по накладной
BEGIN
declare @Our_ID_Saler INT, @dt datetime

    SET @Our_ID_Saler = (SELECT nc.OurID FROM nc WHERE DatNom = @datnom)
    SET @dt = dbo.today()

if object_id('tempdb..#IDList') is not null drop table #IDList
create table #IDList (ID int)

    insert into #IDList (ID) 
    SELECT nv.TekID FROM nv WHERE nv.datnom = @datnom

SELECT t.Hitag, t.name,
       firmsconfig.OurName + ' – ' + (SELECT fc.OurName FROM FirmsConfig fc WHERE fc.Our_id = @Our_ID_Saler) +', '+ convert(VARCHAR, MAX(t.nd), 104) AS DateMove
FROM(
         select n.nd, v.TekID, v.Hitag, e.name,
         ISNULL(s.startid, 0) Id,
         dc.Our_id      
--------------------------------------------------------------------------------------------------------------------------
   from nv v join nc n on v.datnom=n.datnom
             JOIN #IDList ON #IDList.ID = v.TekID
             join nomen e on v.hitag=e.hitag
             --JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             --JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join tdvi s on v.tekid=s.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck         
  where --n.datnom between @datnomStart and @datnomEnd and dc.our_id BETWEEN 1 AND 20 /*=@Our_ID_Owner*/ and 
          n.ourid=@Our_ID_Saler 
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>=0
        and n.nd=@dt

UNION 
         select n.nd, v.TekID, v.Hitag, e.name,
         ISNULL(si.startid, 0) Id, 
         dc.Our_id       
--------------------------------------------------------------------------------------------------------------------------    
  from  nv v join nc n on v.datnom=n.datnom
             JOIN #IDList ON #IDList.ID = v.TekID
             join nomen e on v.hitag=e.hitag
             --JOIN SertifNomenVetCat ON e.hitag = SertifNomenVetCat.Hitag
             --JOIN SertifVetCat ON SertifNomenVetCat.IdCat = SertifVetCat.IdCat
             left join visual si on v.tekid=si.id
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck
  where --n.datnom between @datnomStart and @datnomEnd and dc.our_id BETWEEN 1 AND 20 /*=@Our_ID_Owner*/ and 
        n.ourid=@Our_ID_Saler 
        and d.worker=0 and n.Stip<>4
        and l.Discard=0 and v.kol>=0
        AND n.nd<>@dt
)t
JOIN firmsconfig ON t.our_id = firmsconfig.our_id
GROUP BY t.Hitag, t.name,t.our_id, firmsconfig.ourname 
ORDER BY DateMove ASC 
END