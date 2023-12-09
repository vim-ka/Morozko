CREATE TABLE [dbo].[NomenVendLOG] (
    [Hitag]   INT             NULL,
    [ExtTag]  VARCHAR (20)    NULL,
    [Ncod]    INT             NULL,
    [nd]      DATETIME        NULL,
    [DCK]     INT             NULL,
    [nvk]     INT             NULL,
    [cost]    DECIMAL (15, 2) NULL,
    [price]   DECIMAL (10, 2) NULL,
    [pin]     INT             NULL,
    [IDLog]   INT             IDENTITY (1, 1) NOT NULL,
    [host]    VARCHAR (100)   DEFAULT (host_name()) NULL,
    [LogDate] DATETIME        DEFAULT (getdate()) NULL,
    [program] VARCHAR (100)   DEFAULT (app_name()) NULL,
    [OPType]  INT             NULL,
    CONSTRAINT [NomenVendLOG_pk] PRIMARY KEY CLUSTERED ([IDLog] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ид договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата прихода номенклатуры от Ncod поставщика с DCK договором', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG', @level2type = N'COLUMN', @level2name = N'nd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'внутренний код у поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG', @level2type = N'COLUMN', @level2name = N'ExtTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид номенклатуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG', @level2type = N'COLUMN', @level2name = N'Hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица отношения Номенклатура-Поставщики', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVendLOG';

