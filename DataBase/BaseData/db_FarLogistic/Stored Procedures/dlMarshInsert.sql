CREATE PROCEDURE [db_FarLogistic].dlMarshInsert
@IDCargoMan INT,
@IDDrivers INT,
@IDVehicles INT,
@IDTrailer INT,
@Date_beg DATETIME,
@Date_end DATETIME,
@usr int 

AS

DECLARE @count INT
DECLARE @ID VARCHAR(7)

SELECT @count = COUNT([db_FarLogistic].dlMarsh.dlMarshID)
   				FROM [db_FarLogistic].dlMarsh
        		WHERE (LEFT([db_FarLogistic].dlMarsh.dlMarshID,2) = RIGHT(YEAR(GETDATE()),2))AND
        	  		(RIGHT(LEFT([db_FarLogistic].dlMarsh.dlMarshID,4),2)) = MONTH(GETDATE())

SELECT @ID = RIGHT(CAST(YEAR(GETDATE()) AS VARCHAR(4)),2)+
			(CAST(MONTH(GETDATE()) AS VARCHAR(2)))+
            (RIGHT('00'+CAST(@count +1 AS VARCHAR(3)),3))

INSERT INTO [db_FarLogistic].dlMarsh (
						[db_FarLogistic].dlMarsh.dlMarshID, 
            [db_FarLogistic].dlMarsh.date_creation,
            [db_FarLogistic].dlMarsh.pin,
            [db_FarLogistic].dlMarsh.IDdlDrivers,
            [db_FarLogistic].dlMarsh.IDdlVehicles,
            [db_FarLogistic].dlMarsh.idTrailer,
            [db_FarLogistic].dlMarsh.IDdlMarshStatus, 
            [db_FarLogistic].dlMarsh.dt_beg_plan,
            [db_FarLogistic].dlMarsh.dt_end_plan,
            [db_FarLogistic].dlMarsh.IDUsrPwd)
VALUES	(	@ID,
			GETDATE(),
            @IDCargoMan,
            @IDDrivers,
            @IDVehicles,
            @IDTrailer,
            '1',
            @Date_beg,
            @Date_end,
            @usr)