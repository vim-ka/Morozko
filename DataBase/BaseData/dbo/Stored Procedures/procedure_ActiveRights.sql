CREATE PROCEDURE [dbo].[procedure_ActiveRights] 
@iUIN INTEGER, 
@iPRG INTEGER
AS
DECLARE @iPERM INTEGER
DECLARE @i INTEGER
DECLARE @iLAST INTEGER 
DECLARE @TMP TABLE(i INTEGER)

select @iPerm = Permiss 
FROM PermissCurrent
WHERE (uin = @iUIN)AND(Prg = @iPRG)

SET NOCOUNT ON
DELETE FROM @tmp
SET @iLAST = 1
SET @i = 1
WHILE (@iPERM > 0)
	BEGIN
		IF (@I < @iPERM) 
        	BEGIN            	
                SET @iLAST = @I
            	SET @i = @i * 2
            END
        ELSE
        	BEGIN
            	INSERT INTO @tmp (i) VALUEs (@iLAST)
                SET @iPERM = @iPERM - @iLAST
                SET @i = 1
                SET @iLAST = 1                
            END		
	END

select 	pe.pid 'ID',
		pe.permisname 'Наименование' 
from Permissions pe
where (pe.pID in (SELECT * from @tmp))and(prg = @iPRG)