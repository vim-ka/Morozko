CREATE PROCEDURE ReportUsersOfProgWithRules
@PRG INTEGER
AS
DECLARE @uin_c INTEGER
DECLARE @permiss_c INTEGER
DECLARE @iPERM INTEGER
DECLARE @i INTEGER
DECLARE @iLAST INTEGER 
DECLARE @tmp TABLE (uin_ INTEGER, pID_ INTEGER)

DECLARE t1_cursor CURSOR FOR
SELECT uin,Permiss 
from PermissCurrent 
where Prg = @PRG

SET NOCOUNT ON
DELETE FROM @tmp
OPEN t1_cursor
FETCH NEXT FROM t1_cursor
INTO @uin_c, @permiss_c
WHILE @@FETCH_STATUS = 0
	begin
    	SET @iPERM = @permiss_c
        SET @i = 1
        SET @iLAST = 1
        WHILE (@iPERM > 0)
        BEGIN
        	IF @iPERM > @i
        		BEGIN
            		SET @iLAST = @I
            		SET @i = @i * 2            
            	END
        	ELSE
        		BEGIN
            		INSERT INTO @tmp (uin_, pID_) VALUEs (@uin_c,@iLAST)
                	SET @iPERM = @iPERM - @iLAST
                	SET @i = 1
                	SET @iLAST = 1 
            	END
        END
    FETCH NEXT FROM t1_cursor INTO @uin_c, @permiss_c
    end
CLOSE t1_cursor
DEALLOCATE t1_cursor

SELECT pr.Prg, pr.PrgName ,u.uin, u.login, p.p_id, p.Fio, pe.pID, pe.PermisName FROM @tmp
JOIN usrPwd u on u.uin = uin_
LEFT JOIN Person p on u.p_id = p.P_ID
JOIN Permissions pe on (pe.pID = pID_)and(pe.Prg = @PRG)
JOIN Programs pr ON (pr.prg = @prg)
ORDER BY (u.uin)