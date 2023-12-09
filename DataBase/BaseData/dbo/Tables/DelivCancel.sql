CREATE TABLE [dbo].[DelivCancel] (
    [dk]      INT           IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME      CONSTRAINT [DF__DelivCancel__ND__1DB135A6] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]      VARCHAR (8)   CONSTRAINT [DF__DelivCancel__TM__1EA559DF] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Marsh]   INT           NULL,
    [NDMarsh] DATETIME      NULL,
    [DatNom]  INT           NULL,
    [nvID]    INT           NULL,
    [FCancel] BIT           NULL,
    [OP]      INT           NULL,
    [Remark]  VARCHAR (100) NULL,
    [Verdict] VARCHAR (100) NULL,
    [mhID]    INT           DEFAULT ((-1)) NOT NULL,
    [resID]   INT           DEFAULT ((-1)) NOT NULL,
    [ReqID]   INT           NULL,
    [ReqType] INT           NULL,
    UNIQUE NONCLUSTERED ([dk] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DelivCancel_idx3]
    ON [dbo].[DelivCancel]([nvID] ASC);


GO
CREATE NONCLUSTERED INDEX [DelivCancel_idx2]
    ON [dbo].[DelivCancel]([DatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [DelivCancel_idx]
    ON [dbo].[DelivCancel]([mhID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип заявки
0 - накладная
1 - возврат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivCancel', @level2type = N'COLUMN', @level2name = N'ReqType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Решение оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivCancel', @level2type = N'COLUMN', @level2name = N'Verdict';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание диспетчера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivCancel', @level2type = N'COLUMN', @level2name = N'Remark';

