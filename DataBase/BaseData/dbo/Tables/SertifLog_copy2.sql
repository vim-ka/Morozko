CREATE TABLE [dbo].[SertifLog_copy2] (
    [sid]       INT          IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME     DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [tm]        VARCHAR (8)  DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Act]       VARCHAR (4)  NULL,
    [DatNom]    INT          NULL,
    [Op]        INT          NULL,
    [CompName]  VARCHAR (15) NULL,
    [SertifDoc] INT          NULL,
    CONSTRAINT [SertifLog_uq_copy] UNIQUE NONCLUSTERED ([sid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [SertifLog_idx3]
    ON [dbo].[SertifLog_copy2]([Op] ASC);


GO
CREATE NONCLUSTERED INDEX [SertifLog_idx2]
    ON [dbo].[SertifLog_copy2]([DatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [SertifLog_idx]
    ON [dbo].[SertifLog_copy2]([CompName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifLog_copy2', @level2type = N'COLUMN', @level2name = N'SertifDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кто вводил', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifLog_copy2', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifLog_copy2', @level2type = N'COLUMN', @level2name = N'DatNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время ввода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifLog_copy2', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оператор ввода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifLog_copy2', @level2type = N'COLUMN', @level2name = N'nd';

