---------------синхронизация записей журнала------------------------

CREATE PROCEDURE dbo.SertifCheckStockEntry
        @guid VARCHAR(255), @uuid VARCHAR(255), 
        @vetDocumentUuid VARCHAR(255), @active BIT, 
        @last BIT, @status SMALLINT, 
        @createDate DATETIME, @updateDate DATETIME, 
        @entryNumber VARCHAR(255), @productType SMALLINT, 
        @productGuid VARCHAR(255), @productUuid VARCHAR(255), 
        @SubProductGuid VARCHAR(255), @SubProductUuid VARCHAR(255), 
        @productItemGuid VARCHAR(255), @productItemUuid VARCHAR(255), @volume FLOAT, 
        @unitGuid VARCHAR(255), @unitUuid VARCHAR(255), @prodFirstDate DATETIME, 
        @prodSecondDate DATETIME, @expFirstDate DATETIME, 
        @expSecondDate DATETIME, @perishable BIT, 
        @lowGradeCargo BIT, @countryGuid VARCHAR(255), @countryUuid VARCHAR(255),
        @EnterpriseGuid VARCHAR(255) 

AS 
IF (@active = 1 AND @last = 1) 
BEGIN
  IF NOT EXISTS(SELECT 1 FROM SertifStockEntry
                        WHERE SertifStockEntry.guid = @guid)
                          --AND SertifStockEntry.uuid = @uuid) 
  INSERT INTO SertifStockEntry(guid, uuid, vetDocumentUuid, active, 
                               last, status, createDate, updateDate, 
                               entryNumber, productType, 
                               productGuid, productUuid, 
                               SubProductGuid, SubProductUuid, 
                               productItemGuid, productItemUuid, volume, 
                               unitGuid, unitUuid, prodFirstDate, prodSecondDate,
                               expFirstDate, expSecondDate, perishable, 
                               lowGradeCargo, countryGuid, countryUuid, EnterpriseGuid)
                       VALUES (@guid, @uuid, @vetDocumentUuid, @active, 
                               @last, @status, @createDate, @updateDate, 
                               @entryNumber, @productType, 
                               @productGuid, @productUuid, 
                               @SubProductGuid, @SubProductUuid, 
                               @productItemGuid, @productItemUuid, @volume, 
                               @unitGuid, @unitUuid, @prodFirstDate, @prodSecondDate,
                               @expFirstDate, @expSecondDate, @perishable, 
                               @lowGradeCargo, @countryGuid, @countryUuid, @EnterpriseGuid)
  ELSE
  UPDATE SertifStockEntry
     SET SertifStockEntry.uuid = @uuid,
         SertifStockEntry.vetDocumentUuid = @vetDocumentUuid,
         SertifStockEntry.active = @active, SertifStockEntry.last = @last, 
         SertifStockEntry.status = @status, SertifStockEntry.createDate = @createDate, 
         SertifStockEntry.updateDate = @updateDate, SertifStockEntry.entryNumber = @entryNumber,
         SertifStockEntry.productType = @productType, SertifStockEntry.productGuid = @productGuid, 
         SertifStockEntry.productUuid = @productUuid, SertifStockEntry.SubProductGuid = @SubProductGuid,
         SertifStockEntry.SubProductUuid = @SubProductUuid, SertifStockEntry.productItemGuid = @productItemGuid,
         SertifStockEntry.productItemUuid = @productItemUuid, SertifStockEntry.volume = @volume, 
         SertifStockEntry.unitGuid = @unitGuid, SertifStockEntry.unitUuid = @unitUuid, 
         SertifStockEntry.prodFirstDate = @prodFirstDate, SertifStockEntry.prodSecondDate = @prodSecondDate,
         SertifStockEntry.expFirstDate = @expFirstDate, SertifStockEntry.expSecondDate =@expSecondDate,
         SertifStockEntry.perishable = @perishable, SertifStockEntry.lowGradeCargo = @lowGradeCargo,
         SertifStockEntry.countryGuid = @countryGuid, SertifStockEntry.countryUuid = @countryUuid, 
         SertifStockEntry.EnterpriseGuid = @EnterpriseGuid
   WHERE SertifStockEntry.guid = @guid
     --AND SertifStockEntry.uuid = @uuid
END