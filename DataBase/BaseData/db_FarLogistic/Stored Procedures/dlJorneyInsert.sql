CREATE PROCEDURE [db_FarLogistic].dlJorneyInsert
@IDMarsh INT,
@IDPoint INT,
@IDAction INT,
@IDClient INT,
@IDCount INT,
@Count INT,
@ZeroNum INT
AS
DECLARE @CountRec INT
DECLARE @tmpZ INT

SELECT @CountRec = COUNT(dlJorney.IDdlMarsh) FROM dlJorney WHERE dlJorney.IDdlMarsh = @IDMarsh
SET @CountRec = @CountRec + 1

IF @ZeroNum = 0
BEGIN
SELECT @tmpZ = 1
WHILE EXISTS(SELECT IDdlPointAction FROM dlJorney WHERE (ZeroPoint = @tmpZ))
	SELECT @tmpZ = @tmpZ + 1
END
ELSE
	SET @tmpZ = @ZeroNum

INSERT INTO dlJorney (	IDdlMarsh, 
						IDdlDelivPoint, 
                        IDdlPointAction, 
                        ClientID, 
                        CountID, 
                        Count, 
                        NumberPoint,
                        ZeroPoint)
VALUES				(	@IDMarsh,
                    	@IDPoint,
                    	@IDAction,
                    	@IDClient,
                    	@IDCount,
                    	@Count,
                    	@CountRec,
                        @tmpZ)