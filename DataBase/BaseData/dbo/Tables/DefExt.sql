CREATE TABLE [dbo].[DefExt] (
    [pin]       INT         NOT NULL,
    [LiniaCode] INT         NULL,
    [t]         INT         NULL,
    [ExtPin]    VARCHAR (6) NULL,
    PRIMARY KEY CLUSTERED ([pin] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код ТТ у поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefExt', @level2type = N'COLUMN', @level2name = N'ExtPin';

