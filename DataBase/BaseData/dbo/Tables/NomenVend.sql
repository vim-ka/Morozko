CREATE TABLE [dbo].[NomenVend] (
    [Hitag]     INT             NULL,
    [ExtTag]    VARCHAR (20)    NULL,
    [Ncod]      INT             NULL,
    [nd]        DATETIME        DEFAULT (getdate()) NULL,
    [DCK]       INT             NOT NULL,
    [nvk]       INT             IDENTITY (1, 1) NOT NULL,
    [cost]      DECIMAL (15, 2) NOT NULL,
    [price]     DECIMAL (10, 2) NOT NULL,
    [pin]       INT             NULL,
    [flgWeight] BIT             DEFAULT ((0)) NULL,
    [sklad]     INT             DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [NomenVend_pk] PRIMARY KEY CLUSTERED ([nvk] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NomenVend_Pin]
    ON [dbo].[NomenVend]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [NomenVend_Hitag]
    ON [dbo].[NomenVend]([Hitag] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NomenVend_uq]
    ON [dbo].[NomenVend]([Hitag] ASC, [DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [NomenVend_idx]
    ON [dbo].[NomenVend]([Hitag] ASC, [Ncod] ASC);


GO
CREATE TRIGGER dbo.NomenVend_trd ON dbo.NomenVend
WITH EXECUTE AS CALLER
FOR DELETE
AS
insert into NomenVendLOG (Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,OPType)
select 	Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,2
from deleted
GO
CREATE TRIGGER dbo.NomenVend_tru ON dbo.NomenVend
WITH EXECUTE AS CALLER
FOR UPDATE
AS
insert into NomenVendLOG (Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,OPType)
select 	Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,1
from deleted
GO
CREATE TRIGGER dbo.NomenVend_tri ON dbo.NomenVend
WITH EXECUTE AS CALLER
FOR INSERT
AS
insert into NomenVendLOG (Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,OPType)
select 	Hitag,ExtTag,Ncod,nd,DCK,nvk,cost,price,pin,0
from inserted
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Флаг весового товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'flgWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ид договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата прихода номенклатуры от Ncod поставщика с DCK договором', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'nd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'внутренний код у поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'ExtTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид номенклатуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend', @level2type = N'COLUMN', @level2name = N'Hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица отношения Номенклатура-Поставщики', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenVend';

