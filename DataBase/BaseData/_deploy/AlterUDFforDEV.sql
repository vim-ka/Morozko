PRINT N'Altering config UDFs for DEV environment';

DECLARE @sql NVARCHAR(MAX)

SET @sql = '
ALTER FUNCTION [dbo].[__IS_RELEASE__]
(
)
RETURNS BIT
AS
BEGIN
	RETURN 0
END
'
EXEC (@sql)

SET @sql = '
ALTER FUNCTION [dbo].[__CONFIG_MODE__]()
RETURNS INT AS
BEGIN
	RETURN 1  /* Dev1 */  --0
END
'
EXEC (@sql)

SET @sql = '
ALTER FUNCTION [dbo].[f_Config_AllowNonDomainLogin]
(
)
RETURNS BIT
AS
BEGIN
	
	RETURN 1

END
'
EXEC (@sql)

SET @sql = '
ALTER FUNCTION [dbo].[f_Config_DisablePasswordEnforcement]
(
)
RETURNS BIT
AS
BEGIN
	
	RETURN 0

END
'
EXEC (@sql)
