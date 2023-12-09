CREATE PROCEDURE PermissReplace
@UIN_to INTEGER,
@UIN_from INTEGER
AS

BEGIN TRANSACTION 

DECLARE @curPrg INTEGER
DECLARE @curPermiss INTEGER

--создаем курсор для построчной переборки прав донора
DECLARE n_cursor CURSOR FOR
SELECT p.Prg, p.Permiss 
FROM PermissCurrent p 
WHERE uin = @UIN_from

--удаляем текущие права у конечного пользователя
DELETE FROM PermissCurrent WHERE uin = @UIN_to

--устанавливаем курсор в начальное положение с выгрузкой
--значений в локальные переменные
OPEN n_cursor
FETCH NEXT FROM n_cursor
INTO @curPrg, @curPermiss

--организация цикла перебора записей внутри запроса курсора
WHILE @@FETCH_STATUS = 0 --если равен 0 значит внутри не пусто
BEGIN
-- вставка записей с правами
INSERT INTO PermissCurrent (prg, permiss, uin)
VALUES (@curPrg, @curPermiss, @UIN_to)

FETCH NEXT FROM n_cursor  --перемещение курсора на следующую
INTO @curPrg, @curPermiss --позицию с выгрузкой данных
END

--освобождаем память
CLOSE n_cursor
DEALLOCATE n_cursor
COMMIT