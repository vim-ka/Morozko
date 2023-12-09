CREATE TABLE [dbo].[ReqTypes] (
    [ReqTypeId]      INT           IDENTITY (1, 1) NOT NULL,
    [ReqTypeParent]  INT           NULL,
    [ReqTypeName]    VARCHAR (255) NULL,
    [ReqReglCode]    INT           CONSTRAINT [DF__ReqTypes__ReqReg__314FB0AD] DEFAULT ((1)) NULL,
    [DepId]          INT           CONSTRAINT [DF__ReqTypes__DepId__0941BF53] DEFAULT ((-1)) NULL,
    [IspInterval]    INT           CONSTRAINT [DF__ReqTypes__IspInt__75F9E0B5] DEFAULT ((3)) NULL,
    [NeedFin]        INT           CONSTRAINT [DF__ReqTypes__NeedFi__77E22927] DEFAULT ((0)) NULL,
    [NeedBuh]        INT           CONSTRAINT [DF__ReqTypes__NeedBu__78D64D60] DEFAULT ((0)) NULL,
    [NeedSogl]       INT           CONSTRAINT [DF__ReqTypes__NeedSo__4F35194F] DEFAULT ((0)) NULL,
    [Otv]            INT           CONSTRAINT [DF__ReqTypes__Otv__6EADC4A8] DEFAULT ((-1)) NULL,
    [ReqTypeChecked] INT           CONSTRAINT [DF__ReqTypes__ReqTyp__7D1BDF90] DEFAULT ((0)) NULL,
    [Visible]        BIT           DEFAULT ((1)) NULL,
    CONSTRAINT [UQ__ReqTypes__AC88A41FA62425DF] UNIQUE NONCLUSTERED ([ReqTypeId] ASC)
);


GO


CREATE TRIGGER [dbo].[ReqTypes_UD] ON [dbo].[ReqTypes]
WITH EXECUTE AS CALLER
FOR UPDATE, DELETE
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
  INSERT INTO ReqTypesLog(ReqTypeId, ReqTypeParent, ReqTypeName, ReqReglCode, DepId, IspInterval,
NeedFin, NeedBuh, NeedSogl, Otv, user_id, user_datetime, user_type)
SELECT ReqTypeId, ReqTypeParent, ReqTypeName, ReqReglCode, DepId, IspInterval,
NeedFin, NeedBuh, NeedSogl, Otv,
@user_id, @user_datetime, @user_type from deleted
END
GO


CREATE TRIGGER [dbo].[ReqTypes_I] ON [dbo].[ReqTypes]
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
  INSERT INTO ReqTypesLog(ReqTypeId, ReqTypeParent, ReqTypeName, ReqReglCode, DepId, IspInterval,
NeedFin, NeedBuh, NeedSogl, Otv, user_id, user_datetime, user_type)
SELECT ReqTypeId, ReqTypeParent, ReqTypeName, ReqReglCode, DepId, IspInterval,
NeedFin, NeedBuh, NeedSogl, Otv,
@user_id, @user_datetime, @user_type from inserted
END