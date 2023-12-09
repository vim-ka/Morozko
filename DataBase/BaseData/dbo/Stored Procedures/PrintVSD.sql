CREATE PROCEDURE dbo.PrintVSD @Datnom INT
AS 
SELECT
       SertifVetDocument.VSDnumber, 
       SertifDocumentForm.name AS DocFormName,  -- форма документа
       SertifVetDocument.issueDate,   -- дата оформления
       SertifVetDocument.status,      -- статус: 1=оформлен, 2=аннулирован, 3=погашен 

       IIF(SertifDef.name = '', SertifDef.fio, SertifDef.name) + ', ИНН: ' 
          + SertifDef.inn AS ConsignorBusName, -- фирма-отправитель
       'ТТН: № ' + CAST(dbo.InNnak(@Datnom) AS VARCHAR) + ' от ' + 
       CONVERT(VARCHAR, SertifVetDocument.TTNdate, 104) + ' г' AS TTN,

       (SELECT top 1 IIF(d.name = '', d.fio, d.name) + ', ИНН: ' + d.inn 
          FROM SertifDef d
                      WHERE d.guid = SertifVetDocument.ConsigneeBusGuid
                        AND d.active = 1 AND d.last = 1) AS ConsigneeBusName,  -- фирма-получатель

       (SELECT top 1 se.name + ' (' + se.address + ')'
          FROM SertifEnterprise se
                      WHERE se.guid = SertifVetDocument.ConsigneeEntGuid
                        AND se.active = 1 AND se.last = 1) AS ConsigneeEntName,  -- предприятие-получатель
      
       SertifVetDocument.productItemName, -- продукция
       CAST(SertifVetDocument.volume AS VARCHAR) + ' ' + SertifUnit.name AS volume,  -- объем
       SertifVetDocument.prodFirstDate, SertifVetDocument.prodSecondDate,  -- даты выработки
       
       (SELECT DISTINCT STUFF((select DISTINCT '; ' +  se1.name + ' (' + se1.address + ')'
          FROM SertifProducers
          JOIN SertifEnterprise se1 ON SertifProducers.EnterPriseGuid = se1.guid
                                   AND se1.active = 1 AND se1.last=1 
         WHERE SertifProducers.vetDocumentUuid = SertifVetDocument.uuid
               for xml path(''))
              ,1,2,'')
       ) AS Producer,        -- производители 

       SertifVetDocument.uuid     -- код

  FROM SertifVetDocumentOut 
  JOIN SertifVetDocument ON SertifVetDocumentOut.uuid = SertifVetDocument.uuid
  LEFT JOIN SertifProductItem ON SertifVetDocument.productItemGuid = SertifProductItem.ProductItemGuid
  LEFT JOIN SertifDef ON SertifVetDocument.consignorBusGuid = SertifDef.guid
  LEFT JOIN SertifEnterprise ON SertifVetDocument.consignorEntGuid = SertifEnterprise.guid
  LEFT JOIN SertifUnit ON SertifUnit.guid = SertifVetDocument.unitGuid
  LEFT JOIN SertifDocumentForm ON SertifVetDocument.form = SertifDocumentForm.form

 WHERE SertifVetDocumentOut.datnom = @Datnom
   AND SertifDef.active = 1 AND SertifDef.last = 1
   AND SertifEnterprise.active = 1 AND SertifEnterprise.last = 1
   AND (SertifProductItem.active = 1 OR SertifProductItem.active IS NULL)
   AND (SertifProductItem.last = 1 OR SertifProductItem.last IS NULL)
   AND SertifUnit.active = 1 AND SertifUnit.last = 1