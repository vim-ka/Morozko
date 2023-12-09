CREATE TABLE [dbo].[GLNList] (
    [gln]     VARCHAR (50)  NOT NULL,
    [name]    VARCHAR (60)  NOT NULL,
    [city]    VARCHAR (40)  NULL,
    [addr]    VARCHAR (230) NOT NULL,
    [index]   VARCHAR (10)  NULL,
    [regcode] CHAR (2)      NULL,
    [CLID]    INT           CONSTRAINT [DF__GLNList__CLID__7C12ACBE] DEFAULT ((1)) NULL,
    [pin]     INT           NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [GLNList_uq]
    ON [dbo].[GLNList]([gln] ASC, [CLID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента в Def', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GLNList', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД клиента, см.Exite_Clients', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GLNList', @level2type = N'COLUMN', @level2name = N'CLID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код региона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GLNList', @level2type = N'COLUMN', @level2name = N'regcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'индекс', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GLNList', @level2type = N'COLUMN', @level2name = N'index';

