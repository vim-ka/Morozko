CREATE PROCEDURE PermissAdd
@UIN_to INTEGER,
@UIN_fr INTEGER
AS

BEGIN TRANSACTION

DECLARE @curPrg_to INTEGER
DECLARE @curPermiss_to INTEGER
DECLARE @curPrg_fr INTEGER
DECLARE @curPermiss_fr INTEGER
DECLARE @tmp_to TABLE (i INTEGER)
DECLARE @tmp_fr TABLE (i INTEGER)
DECLARE @i INTEGER
DECLARE @iLast INTEGER
DECLARE @iPerm INTEGER
DECLARE @curpID INTEGER


--создаем курсор для построчной переборки прав донора
DECLARE fr_cursor CURSOR FOR
SELECT prg, permiss 
FROM PermissCurrent
WHERE uin = @UIN_fr

--создаем курсор для построчной переборки прав ресипиента
DECLARE to_cursor CURSOR FOR
SELECT prg, permiss 
FROM PermissCurrent
WHERE uin = @UIN_to

--создаем курсор для построчной переборки прав
DECLARE tmp_cursor CURSOR FOR
SELECT i FROM @tmp_fr

--устанавливаем курсор в начальное положение с выгрузкой
--значений в локальные переменные донора 
OPEN fr_cursor
FETCH NEXT FROM fr_cursor
INTO @curPrg_fr, @curPermiss_fr

--начинаем перебор данных донора
WHILE @@FETCH_STATUS = 0
	BEGIN    
	OPEN to_cursor
	FETCH NEXT FROM to_cursor
	INTO @curPrg_to, @curPermiss_to
	
    WHILE @@FETCH_STATUS = 0
	IF @curPrg_fr IN (SELECT PermissCurrent.prg 
    					FROM PermissCurrent
                        WHERE PermissCurrent.uin = @UIN_to)
 		BEGIN       
    	DELETE FROM @tmp_to
        DELETE FROM @tmp_fr
------------заполненине временной таблицы прав ресипиента        
        SET @iPERM = @curPermiss_to
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
            		INSERT INTO @tmp_to (i) VALUEs (@iLAST)
                	SET @iPERM = @iPERM - @iLAST
                	SET @i = 1
                	SET @iLAST = 1 
            	END
        END
------------заполненине временной таблицы прав донора            
 		SET @iPERM = @curPermiss_fr
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
            		INSERT INTO @tmp_fr (i) VALUEs (@iLAST)
                	SET @iPERM = @iPERM - @iLAST
                	SET @i = 1
                	SET @iLAST = 1 
            	END
        END
    
    OPEN tmp_cursor
    FETCH NEXT FROM tmp_cursor
    INTO @curpID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
    	IF not(@curpID in (SELECT i FROM @tmp_to))
    	BEGIN
    		UPDATE PermissCurrent 
    		SET PermissCurrent.Permiss = PermissCurrent.Permiss + @curpID
            WHERE (PermissCurrent.uin = @UIN_to) and (PermissCurrent.Prg = @curPrg_to)
    		BREAK
    	END
    	ELSE
    	BEGIN    		
            FETCH NEXT FROM tmp_cursor
    		INTO @curpID
    	END    
    END   
    CLOSE tmp_cursor
    
    FETCH NEXT FROM to_cursor
	INTO @curPrg_to, @curPermiss_to
    END
    ELSE    
    BEGIN
    	INSERT INTO PermissCurrent (uin, prg, permiss)
        VALUES (@UIN_to, @curPrg_fr, @curPermiss_fr)        
        BREAK
    END
	CLOSE to_cursor    
    FETCH NEXT FROM fr_cursor
	INTO @curPrg_fr, @curPermiss_fr    
    END	
--освобождаем память
CLOSE fr_cursor

DEALLOCATE fr_cursor
DEALLOCATE to_cursor
DEALLOCATE tmp_cursor
COMMIT