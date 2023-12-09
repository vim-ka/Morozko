CREATE TABLE [dbo].[Config] (
    [param]   VARCHAR (50)  NULL,
    [val]     VARCHAR (50)  NULL,
    [comment] VARCHAR (100) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Config', @level2type = N'COLUMN', @level2name = N'comment';

