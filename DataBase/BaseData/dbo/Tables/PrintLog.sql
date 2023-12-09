CREATE TABLE [dbo].[PrintLog] (
    [ND]       DATETIME     NULL,
    [SourceOP] INT          NULL,
    [PrintOp]  INT          NULL,
    [SellDate] DATETIME     NULL,
    [Nnak]     INT          NULL,
    [CompName] VARCHAR (20) NULL,
    [Tip]      INT          NULL,
    [plId]     INT          IDENTITY (1, 1) NOT NULL,
    [DatNom]   BIGINT       NULL,
    [Remark]   VARCHAR (50) NULL,
    CONSTRAINT [PrintLog_pk] PRIMARY KEY CLUSTERED ([plId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [PrintLog_idx2]
    ON [dbo].[PrintLog]([CompName] ASC);


GO
CREATE NONCLUSTERED INDEX [PrintLog_idx3]
    ON [dbo].[PrintLog]([DatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [PrintLog_idx]
    ON [dbo].[PrintLog]([Nnak] ASC, [SellDate] ASC);


GO
CREATE TRIGGER [dbo].[PrintLog_tri] ON [dbo].[PrintLog]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
declare @nnak int
declare @SellDate datetime
declare @plID int
set @nnak=(select nnak from inserted)
set @SellDate=(select SellDate from inserted)
set @plID=(select plId from inserted)
update PrintLog set PrintLog.Datnom=dbo.InDatNom(@Nnak,@Selldate)
where PrintLog.plId=@plID
END