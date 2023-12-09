CREATE PROCEDURE dbo.SertifUnloadAlienRealizMerc @Our_ID_Owner int, @Our_ID_Saler int, @DateStart datetime, @DateEnd datetime
AS  --список продукции для перемещения в Меркурий
BEGIN
------------------------------------------------------------------------------------------------------------------------------
DECLARE @datnomStart bigint, @datnomEnd bigint, @dt DATETIME

SET @datnomStart = dbo.InDatNom(0,@DateStart)
SET @datnomEnd = dbo.InDatNom(9999,@DateEnd)
SET @dt = dbo.today()

SELECT TEMP.Hitag, TEMP.ProductItemId, 
       SUM(TEMP.kol) AS kol, SUM(TEMP.weight) AS weight,
       TEMP.unit, 
       SUM(TEMP.sp) AS sp,  SUM(TEMP.sl) AS sl, 
       TEMP.name, TEMP.Id, TEMP.uuid, TEMP.productItemName, TEMP.outVSD 
FROM
(
   select v.nvId, 
         v.hitag, SertifProductItemLink.ProductItemId,
         v.kol as kol, v.kol*v.cost as sp, v.kol*v.price*(1.0+n.extra/100) as sl, 
         IIF(e.flgWeight = 0, v.kol*e.netto, v.kol*s.weight) AS weight,      --IIF(e.flgWeight = 0, v.kol*e.netto, s.weight) AS weight 
         iif(e.flgWeight = 0, 'шт', 'кг') AS unit,
         e.name as [name],  
         s.startid Id, 
         SertifVetDocument.uuid, 
         iif(SertifProductItem.name IS NOT NULL, SertifProductItem.name, SertifVetDocument.productItemName) AS productItemName,
         SertifVetDocumentOUT.uuid AS outVSD 

--------------------------------------------------------------------------------------------------------------------------
  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             LEFT JOIN SertifProductItemLink ON e.hitag = SertifProductItemLink.hitag   
             LEFT JOIN SertifProductItem ON SertifProductItemLink.ProductItemId = SertifProductItem.ProductItemId       --JOIN!!!
             left join tdvi s on v.tekid=s.id
            JOIN SertifInpdetStock ON s.startid = SertifInpdetStock.StartID AND SertifInpdetStock.Our_id = @Our_ID_Owner
            JOIN Sertifstockentry ON SertifInpdetStock.EntryID = SertifStockEntry.EntryID
             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = s.dck
             left join InpdetVetSvid ON s.startid = InpdetVetSvid.Id AND InpdetVetSvid.OurID = @Our_ID_Owner
             left join SertifVetDocument ON InpdetVetSvid.VetUuid = SertifVetDocument.uuid 
             LEFT JOIN SertifVetDocumentOUT ON v.nvId = SertifVetDocumentOUT.nvId
                                           AND SertifVetDocumentOUT.OurID = @Our_ID_Owner 

  WHERE n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler 
    AND d.worker=0 and n.Stip<>4
    AND l.Discard=0 and v.kol>0
    AND n.nd=@dt
    --AND SertifProductItemLink.ProductItemId <> -1   --только подконтрольная (связанная с меркурием)
    AND SertifVetDocument.status = 3    --только погашенные
    --AND   --исключить строки, на которые исходящий ВСД уже оформлен   
UNION 

select   v.nvId,
         v.hitag, SertifProductItemLink.ProductItemId,
         v.kol as kol, v.kol*v.cost as sp, v.kol*v.price*(1.0+n.extra/100) as sl, 
         IIF(e.flgWeight = 0, v.kol*e.netto, v.kol*si.weight) AS weight,    --IIF(e.flgWeight = 0, v.kol*e.netto, si.weight) AS weight,
         iif(e.flgWeight = 0, 'шт', 'кг') AS unit,
         e.name as [name],  
         ISNULL(si.startid, 0) Id, 
         SertifVetDocument.uuid,
         iif(SertifProductItem.name IS NOT NULL, SertifProductItem.name, SertifVetDocument.productItemName) AS productItemName,
         SertifVetDocumentOUT.uuid AS outVSD

  from  nv v join nc n on v.datnom=n.datnom
             join nomen e on v.hitag=e.hitag
             LEFT JOIN SertifProductItemLink ON e.hitag = SertifProductItemLink.hitag
             LEFT JOIN SertifProductItem ON SertifProductItemLink.ProductItemId = SertifProductItem.ProductItemId     --JOIN!!!
             left join visual si on v.tekid=si.id
            JOIN SertifInpdetStock ON si.startid = SertifInpdetStock.StartID AND SertifInpdetStock.Our_id = @Our_ID_Owner
            JOIN Sertifstockentry ON SertifInpdetStock.EntryID = SertifStockEntry.EntryID

             left join def d on n.b_id=d.pin   
             left join skladlist l on v.sklad=l.skladno
             left join defcontract dc on dc.dck = si.dck 
             left join InpdetVetSvid ON si.startid = InpdetVetSvid.Id AND InpdetVetSvid.OurID = @Our_ID_Owner
             left join SertifVetDocument ON InpdetVetSvid.VetUuid = SertifVetDocument.uuid 
             LEFT JOIN SertifVetDocumentOUT ON v.nvId = SertifVetDocumentOUT.nvId 
                                           AND SertifVetDocumentOUT.OurID = @Our_ID_Owner

  WHERE n.datnom between @datnomStart and @datnomEnd and dc.our_id=@Our_ID_Owner and n.ourid=@Our_ID_Saler 
    AND d.worker=0 and n.Stip<>4
    AND l.Discard=0 and v.kol>0
    AND n.nd<>@dt
    --AND SertifProductItemLink.ProductItemId <> -1   --только подконтрольная (связанная с меркурием)
    AND SertifVetDocument.status = 3  --только погашенные
    --AND   --исключить строки, на которые исходящий ВСД уже оформлен   

) TEMP
GROUP BY TEMP.Hitag, TEMP.ProductItemId, TEMP.name, TEMP.unit, TEMP.Id, TEMP.uuid, TEMP.productItemName, TEMP.outVSD


ORDER BY name ASC

END