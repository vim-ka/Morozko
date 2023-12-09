------------------------Синхронизация ВСД---------------------------------------------

CREATE PROCEDURE dbo.SertifCheckVetDocument  
        @uuid VARCHAR(255), @issueSeries VARCHAR(255), @issueNumber VARCHAR(255),
        @issueDate DATETIME, @form SMALLINT, @type SMALLINT, @status SMALLINT,
        @ConsignorBusGuid VARCHAR(255), @ConsignorBusUuid VARCHAR(255), 
        @ConsignorEntGuid VARCHAR(255), @ConsignorEntUuid VARCHAR(255),
        @ConsigneeBusGuid VARCHAR(255), @ConsigneeBusUuid VARCHAR(255), 
        @ConsigneeEntGuid VARCHAR(255), @ConsigneeEntUuid VARCHAR(255),
        @transportType SMALLINT, @vehicleNumber VARCHAR(255), 
        @containerNumber VARCHAR(255), @trailerNumber VARCHAR(255),
        @transportStorageType SMALLINT, @productType SMALLINT,
        @productGuid VARCHAR(255), @productUuid VARCHAR(255), 
        @SubProductGuid VARCHAR(255), @SubProductUuid VARCHAR(255),
        @productItemGuid VARCHAR(255), @productItemUuid VARCHAR(255), 
        @productItemName VARCHAR(255), --@globalId VARCHAR(255), @code VARCHAR(255),
        @volume FLOAT,      
        @unitGuid VARCHAR(255), @unitUuid VARCHAR(255), @prodFirstDate DATETIME,
        @prodSecondDate DATETIME, @expFirstDate DATETIME,
        @expSecondDate DATETIME, @perishable BIT,
        @lowGradeCargo BIT, @countryGuid VARCHAR(255), @countryUuid VARCHAR(255),
        @cargoInspected BIT, @cargoExpertized SMALLINT,
        @locationProsperity VARCHAR(255), @specialMarks VARCHAR(8000),
        @purposeGuid VARCHAR(255), @purposeUuid VARCHAR(255), 
        @TTNtype SMALLINT = 1, @TTNSeries VARCHAR(255) = '', @TTNnum VARCHAR(255), @TTNdate DATETIME,
        @ProducerList VARCHAR(MAX) = '', @RoleList VARCHAR(MAX) = '', @BatchIdList VARCHAR(MAX) = '' 

AS 
             
IF NOT EXISTS (SELECT 1 FROM SertifVetDocument
                       WHERE SertifVetDocument.uuid = @uuid)
INSERT INTO SertifVetDocument
            (uuid, issueSeries, 
             issueNumber, issueDate,
             form, type, status, 
             ConsignorBusGuid, ConsignorBusUuid,
             ConsignorEntGuid, ConsignorEntUuid, 
             ConsigneeBusGuid, ConsigneeBusUuid,
             ConsigneeEntGuid, ConsigneeEntUuid, 
             transportType, vehicleNumber, containerNumber,
             trailerNumber, transportStorageType,
             productType, productGuid, productUuid, 
             SubProductGuid, SubProductUuid, 
             productItemGuid, productItemUuid, productItemName,
             volume, unitGuid, unitUuid,
             prodFirstDate, prodSecondDate,
             expFirstDate, expSecondDate,
             perishable, lowGradeCargo,
             countryGuid, countryUuid, cargoInspected, cargoExpertized,
             locationProsperity, specialMarks, purposeGuid, purposeUuid,
             TTNtype, TTNSeries, TTNnum, TTNdate)
      VALUES(@uuid, @issueSeries, 
             @issueNumber, @issueDate,
             @form, @type, @status, 
             @ConsignorBusGuid, @ConsignorBusUuid,
             @ConsignorEntGuid, @ConsignorEntUuid, 
             @ConsigneeBusGuid, @ConsigneeBusUuid,
             @ConsigneeEntGuid, @ConsigneeEntUuid, 
             @transportType, @vehicleNumber, @containerNumber, 
             @trailerNumber, @transportStorageType,
             @productType, @productGuid, @productUuid, 
             @SubProductGuid, @SubProductUuid, 
             @productItemGuid, @productItemUuid, @productItemName,
             @volume, @unitGuid, @unitUuid,
             @prodFirstDate, @prodSecondDate,
             @expFirstDate, @expSecondDate,
             @perishable, @lowGradeCargo,
             @countryGuid, @countryUuid, @cargoInspected, @cargoExpertized,
             @locationProsperity, @specialMarks, @purposeGuid, @purposeUuid,
             @TTNtype, @TTNSeries, @TTNnum, @TTNdate)   
ELSE 
  UPDATE SertifVetDocument
     SET SertifVetDocument.issueSeries = @issueSeries,
         SertifVetDocument.issueNumber = @issueNumber,
         SertifVetDocument.issueDate = @issueDate,
         SertifVetDocument.form = @form,
         SertifVetDocument.type = @type,
         SertifVetDocument.status = @status,
         SertifVetDocument.ConsignorBusGuid = @ConsignorBusGuid,
         SertifVetDocument.ConsignorBusUuid = @ConsignorBusUuid,
         SertifVetDocument.ConsignorEntGuid = @ConsignorEntGuid,
         SertifVetDocument.ConsignorEntUuid = @ConsignorEntUuid,
         SertifVetDocument.ConsigneeBusGuid = @ConsigneeBusGuid,
         SertifVetDocument.ConsigneeBusUuid = @ConsigneeBusUuid,
         SertifVetDocument.ConsigneeEntGuid = @ConsigneeEntGuid,
         SertifVetDocument.ConsigneeEntUuid = @ConsigneeEntUuid,
         SertifVetDocument.transportType = @transportType,
         SertifVetDocument.vehicleNumber = @vehicleNumber,
         SertifVetDocument.containerNumber = @containerNumber,
         SertifVetDocument.trailerNumber = @trailerNumber, 
         SertifVetDocument.transportStorageType = @transportStorageType,
         SertifVetDocument.productType = @productType,
         SertifVetDocument.productGuid = @productGuid,
         SertifVetDocument.productUuid = @productUuid,
         SertifVetDocument.SubProductGuid = @SubProductGuid,
         SertifVetDocument.SubProductUuid = @SubProductUuid,
         SertifVetDocument.productItemGuid = @productItemGuid,
         SertifVetDocument.productItemUuid = @productItemUuid,
         SertifVetDocument.productItemName = @productItemName,
         SertifVetDocument.volume = @volume,
         SertifVetDocument.unitGuid = @unitGuid,
         SertifVetDocument.unitUuid = @unitUuid,
         SertifVetDocument.prodFirstDate = @prodFirstDate,
         SertifVetDocument.prodSecondDate = @prodSecondDate,
         SertifVetDocument.expFirstDate = @expFirstDate,
         SertifVetDocument.expSecondDate = @expSecondDate,
         SertifVetDocument.perishable = @perishable,
         SertifVetDocument.lowGradeCargo = @lowGradeCargo,
         SertifVetDocument.countryGuid = @countryGuid,
         SertifVetDocument.countryUuid = @countryUuid,
         SertifVetDocument.cargoInspected = @cargoInspected,
         SertifVetDocument.cargoExpertized = @cargoExpertized,
         SertifVetDocument.locationProsperity = @locationProsperity,
         SertifVetDocument.specialMarks = @specialMarks,
         SertifVetDocument.purposeGuid = @purposeGuid,
         SertifVetDocument.purposeUuid = @purposeUuid, 
         SertifVetDocument.TTNtype = @TTNtype,
         SertifVetDocument.TTNSeries = @TTNSeries,
         SertifVetDocument.TTNnum = @TTNnum,
         SertifVetDocument.TTNdate = @TTNdate  
   WHERE SertifVetDocument.uuid = @uuid
/*
--заполнение списка производителей
if @ProducerList <> ''
BEGIN
  if object_id('tempdb..#ProducerList') is not null drop table #ProducerList
  create table #ProducerList(guid VARCHAR(255))
      insert into #ProducerList(guid) 
      select K as guid from dbo.Str2Strarray(@ProducerList) 
 
      INSERT INTO SertifProducers(EnterpriseGuid, vetDocumentUuid)
        SELECT #ProducerList.guid, @uuid
          FROM #ProducerList
         WHERE NOT EXISTS(SELECT 1 FROM SertifProducers
                       WHERE SertifProducers.EnterpriseGuid = #ProducerList.guid 
                         AND SertifProducers.vetDocumentUuid = @uuid)

/*
      declare @EnterpriseUuid VARCHAR(255)           
      declare C cursor fast_forward local 
      for select #ProducerList.uuid from #ProducerList      
      open C 
      fetch next from C 
      into @EnterpriseUuid          
      while @@FETCH_STATUS = 0
      begin
        IF NOT EXISTS(SELECT 1 FROM SertifProducers
                       WHERE SertifProducers.EnterpriseUuid = @EnterpriseUuid 
                         AND SertifProducers.vetDocumentUuid = @uuid)           
        INSERT INTO SertifProducers(EnterpriseUuid, vetDocumentUuid)
        SELECT #ProducerList.uuid, @uuid
          FROM #ProducerList        
        
        fetch next from C 
        into @EnterpriseUuid
      end     

      close C;
      deallocate C; 
*/

END
*/

--заполнение BatchID
if @BatchIDList <> ''
BEGIN
  if object_id('tempdb..#BatchIDList') is not null drop table #BatchIDList
  create table #BatchIDList(BatchID VARCHAR(255))
      insert into #BatchIDList(BatchID) 
      select K as BatchID from dbo.Str2Strarray(@BatchIDList) 
 
      INSERT INTO SertifBatch(BatchID, vetDocumentUuid)
        SELECT #BatchIDList.BatchID, @uuid
          FROM #BatchIDList
         WHERE NOT EXISTS(SELECT 1 FROM SertifBatch
                       WHERE SertifBatch.BatchID = #BatchIDList.BatchID 
                         AND SertifBatch.vetDocumentUuid = @uuid)

END
ELSE DELETE FROM SertifBatch WHERE SertifBatch.vetDocumentUuid = @uuid