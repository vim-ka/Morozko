CREATE PROCEDURE dbo.dlMarshInsert
@IDCargoMan INT,
@IDDrivers INT,
@IDVehicles INT,
@IDTrailer INT,
@Date_beg DATETIME,
@Date_end DATETIME

AS

DECLARE @count INT
DECLARE @ID VARCHAR(7)

SELECT @count = COUNT(dlMarsh.dlMarshID)
   				FROM dlMarsh
        		WHERE (LEFT(dlMarsh.dlMarshID,2) = RIGHT(YEAR(GETDATE()),2))AND
        	  		(RIGHT(LEFT(dlMarsh.dlMarshID,4),2)) = MONTH(GETDATE())

SELECT @ID = RIGHT(CAST(YEAR(GETDATE()) AS VARCHAR(4)),2)+
			(CAST(MONTH(GETDATE()) AS VARCHAR(2)))+
            (RIGHT('00'+CAST(@count +1 AS VARCHAR(3)),3))

INSERT INTO dlMarsh (
			dlMarsh.dlMarshID, 
            dlMarsh.date_creation,
            dlMarsh.pin,
            dlMarsh.IDdlDrivers,
            dlMarsh.IDdlVehicles,
            dlMarsh.idTrailer,
            dlMarsh.IDdlMarshStatus, 
            dlMarsh.dt_beg_plan,
            dlMarsh.dt_end_plan)
VALUES	(	@ID,
			GETDATE(),
            @IDCargoMan,
            @IDDrivers,
            @IDVehicles,
            @IDTrailer,
            '1',
            @Date_beg,
            @Date_end)