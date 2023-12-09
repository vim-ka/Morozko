CREATE TABLE [dbo].[exite_ClientsExchange] (
    [ClEx]       INT          IDENTITY (1, 1) NOT NULL,
    [CLID]       INT          NULL,
    [Type]       VARCHAR (10) NULL,
    [login]      VARCHAR (20) NULL,
    [pass]       VARCHAR (30) NULL,
    [active]     BIT          NULL,
    [ImportPath] VARCHAR (50) NULL,
    [ExportPath] VARCHAR (50) NULL,
    [Address]    VARCHAR (70) NULL,
    [StopND]     DATETIME     NULL,
    UNIQUE NONCLUSTERED ([ClEx] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_ClientsExchange', @level2type = N'COLUMN', @level2name = N'Address';

