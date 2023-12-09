CREATE TABLE [dbo].[exite_Companys] (
    [id]    INT           IDENTITY (1, 1) NOT NULL,
    [name]  VARCHAR (30)  NOT NULL,
    [login] VARCHAR (20)  NOT NULL,
    [pass]  VARCHAR (20)  NOT NULL,
    [gln]   VARCHAR (13)  NOT NULL,
    [ftp]   VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([login] ASC),
    UNIQUE NONCLUSTERED ([name] ASC),
    UNIQUE NONCLUSTERED ([pass] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'адрес ftp для обмена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_Companys', @level2type = N'COLUMN', @level2name = N'ftp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'пароль на ftp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_Companys', @level2type = N'COLUMN', @level2name = N'pass';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'логин на ftp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_Companys', @level2type = N'COLUMN', @level2name = N'login';

