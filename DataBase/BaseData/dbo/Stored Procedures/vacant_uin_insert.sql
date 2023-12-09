CREATE PROCEDURE vacant_uin_insert
@LOGIN VARCHAR(20),
@PWD VARCHAR(32),
@P_ID INTEGER
AS
DECLARE @uin INT

SET @uin = 100
WHILE (@uin IN (SELECT uin FROM usrPwd))
BEGIN
	SET @uin = @uin + 1
END

INSERT INTO usrPWD (uin, p_id, login, pwd, fio)
VALUES (@uin, @p_id, @login, @pwd, (select fio from person where p_id = @p_id))

insert into permisscurrent(uin,p_id,prg,permiss) values(@uin, @p_id, 17,1)