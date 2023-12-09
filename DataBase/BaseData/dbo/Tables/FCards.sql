CREATE TABLE [dbo].[FCards] (
    [fcID]        INT           IDENTITY (1, 1) NOT NULL,
    [CardNom]     VARCHAR (25)  NULL,
    [FuelCardTip] INT           NULL,
    [ND]          DATETIME      NULL,
    [TypeFuel]    TINYINT       NULL,
    [Limit]       INT           NULL,
    [uin]         INT           NULL,
    [RazrLimit]   INT           NULL,
    [Status]      INT           NULL,
    [NDRET]       DATETIME      NULL,
    [fcBlBegDate] DATETIME      NULL,
    [fcBlEndDate] DATETIME      NULL,
    [Org]         INT           NULL,
    [pin]         VARCHAR (4)   NULL,
    [lostcard_id] INT           NULL,
    [prim]        VARCHAR (300) NULL,
    [p_id]        INT           NULL,
    [idvehicle]   INT           DEFAULT ((-1)) NULL,
    [vehiclebeg]  DATETIME      NULL,
    [vehicleend]  DATETIME      NULL,
    UNIQUE NONCLUSTERED ([fcID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FCards_idx2]
    ON [dbo].[FCards]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [FCards_idx]
    ON [dbo].[FCards]([CardNom] ASC);


GO
CREATE TRIGGER dbo.FCards_I ON dbo.FCards
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  DECLARE @user_id as int;
  DECLARE @user_datetime as datetime;  
  DECLARE @user_type as char(3);
  SET @user_id = 0;
  SET @user_datetime = GETDATE();
  SET @user_type = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                      AND EXISTS(SELECT * FROM DELETED)
                      THEN 'UPD'
                      WHEN EXISTS(SELECT * FROM INSERTED)
                      THEN 'INS'
                      WHEN EXISTS(SELECT * FROM DELETED)
                      THEN 'DEL'
                      ELSE NULL
                  END)
  INSERT INTO FCardsLog(CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
fclUsr, fclDate, fclTypeOp, idvehicle, vehiclebeg, vehicleend)
SELECT CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
@user_id, @user_datetime, @user_type, idvehicle, vehiclebeg, vehicleend from inserted
END
GO
CREATE TRIGGER dbo.FCards_D ON dbo.FCards
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  DECLARE @user_id as int;
  DECLARE @user_datetime as datetime;  
  DECLARE @user_type as char(3);
  SET @user_id = 0;
  SET @user_datetime = GETDATE();
  SET @user_type = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                      AND EXISTS(SELECT * FROM DELETED)
                      THEN 'UPD'
                      WHEN EXISTS(SELECT * FROM INSERTED)
                      THEN 'INS'
                      WHEN EXISTS(SELECT * FROM DELETED)
                      THEN 'DEL'
                      ELSE NULL
                  END)
  INSERT INTO FCardsLog(CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
fclUsr, fclDate, fclTypeOp, idvehicle, vehiclebeg, vehicleend)
SELECT CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
@user_id, @user_datetime, @user_type, idvehicle, vehiclebeg, vehicleend from deleted
END
GO
CREATE TRIGGER dbo.FCards_U ON dbo.FCards
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  DECLARE @user_id as int;
  DECLARE @user_datetime as datetime;  
  DECLARE @user_type as char(3);
  SET @user_id = 0;
  SET @user_datetime = GETDATE();
  SET @user_type = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                      AND EXISTS(SELECT * FROM DELETED)
                      THEN 'UPD'
                      WHEN EXISTS(SELECT * FROM INSERTED)
                      THEN 'INS'
                      WHEN EXISTS(SELECT * FROM DELETED)
                      THEN 'DEL'
                      ELSE NULL
                  END)
  INSERT INTO FCardsLog(CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
fclUsr, fclDate, fclTypeOp, idvehicle, vehiclebeg, vehicleend)
SELECT CardNom, FuelCardTip, ND, TypeFuel, Limit, uin, Status, NDRET,
fcBlBegDate, fcBlEndDate, Org, pin, lostcard_id, prim, p_id,
@user_id, @user_datetime, @user_type, idvehicle, vehiclebeg, vehicleend from deleted
END