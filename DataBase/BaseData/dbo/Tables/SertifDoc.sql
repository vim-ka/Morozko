CREATE TABLE [dbo].[SertifDoc] (
    [dNo]   INT          NOT NULL,
    [dName] VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([dNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование документов сертификации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDoc', @level2type = N'COLUMN', @level2name = N'dName';

