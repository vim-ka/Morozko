--результат оформления исходящих ВСД для заданной накладной
CREATE FUNCTION dbo.SertifCheckVSDOUT (@datnom INT)
RETURNS int
AS
BEGIN

DECLARE @res INT,
        @VSDall INT, @VSDcount INT  

SET @VSDall = (SELECT COUNT(NV.nvId) 
                 FROM NV
                 JOIN SertifProductItemLink ON NV.Hitag = SertifProductItemLink.hitag
                WHERE NV.DatNom = @datnom
                  AND SertifProductItemLink.ProductItemId <> -1)   --только подконтрольная продукция

SET @VSDcount = (SELECT COUNT(SertifVetDocumentOUT.uuid)
                   FROM NV
                   JOIN SertifProductItemLink ON NV.Hitag = SertifProductItemLink.hitag
                   JOIN SertifVetDocumentOUT ON NV.nvId = SertifVetDocumentOUT.nvId 
                  WHERE NV.DatNom = @datnom
                    AND SertifVetDocumentOUT.uuid IS NOT NULL) 

SELECT @res =
(
SELECT CASE 
    WHEN @VSDall = 0 THEN 0                           --не требуются ВСД 
    WHEN @VSDall > 0 AND @VSDcount = 0 THEN 1         --ВСД требуются, не оформлено ни одного
    WHEN @VSDall > @VSDcount THEN 2                   --ВСД требуются, оформлены не все
    WHEN @VSDall > 0 AND @VSDall = @VSDcount THEN 3   --ВСД требуются, оформлены все
   END AS res 
)
RETURN @res
END