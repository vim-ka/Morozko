CREATE TABLE [dbo].[Units] (
    [UnID]       INT         IDENTITY (0, 1) NOT NULL,
    [UnitName]   VARCHAR (5) NULL,
    [OKEI]       VARCHAR (5) NULL,
    [GlobalName] VARCHAR (5) NULL,
    PRIMARY KEY CLUSTERED ([UnID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'http://classifikators.ru/okei', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Units', @level2type = N'COLUMN', @level2name = N'OKEI';

