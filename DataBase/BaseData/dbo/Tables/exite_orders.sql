CREATE TABLE [dbo].[exite_orders] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [ND]                DATETIME      DEFAULT (getdate()) NULL,
    [DocNumber]         VARCHAR (35)  NOT NULL,
    [date]              VARCHAR (20)  NOT NULL,
    [DeliveryDate]      VARCHAR (20)  NOT NULL,
    [DeliveryTime]      VARCHAR (5)   NULL,
    [SupplierGLN]       VARCHAR (50)  NOT NULL,
    [BuyerGLN]          VARCHAR (100) NULL,
    [DeliveryPlaceGLN]  VARCHAR (50)  NULL,
    [InvoicePartnerGLN] VARCHAR (240) NULL,
    [SenderGLN]         VARCHAR (100) NOT NULL,
    [FinalRecipientGLN] VARCHAR (50)  NULL,
    [RecipientGLN]      VARCHAR (50)  NOT NULL,
    [EdiInterGhangeID]  VARCHAR (100) NULL,
    [xml]               XML           NULL,
    [Status]            INT           CONSTRAINT [DF__exite_ord__Statu__4362A899] DEFAULT ((0)) NOT NULL,
    [owner_id]          INT           CONSTRAINT [DF__exite_ord__owner__03482384] DEFAULT ((0)) NOT NULL,
    [ediID]             INT           NULL,
    [Remark]            VARCHAR (200) NULL,
    [STip]              SMALLINT      CONSTRAINT [DF__exite_orde__Actn__0B0AD78B] DEFAULT ((0)) NULL,
    [CLID]              INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [exite_orders_fk] FOREIGN KEY ([Status]) REFERENCES [dbo].[exite_orderStatus] ([id]),
    CONSTRAINT [exite_orders_uq] UNIQUE NONCLUSTERED ([DocNumber] ASC, [ediID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип отгрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'STip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание к заявке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код edi провайдера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'ediID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статус заказа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер транзакции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'EdiInterGhangeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN получателя сообщения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'RecipientGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN конечного консигнатора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'FinalRecipientGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN отправителя сообщения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'SenderGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN плательщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'InvoicePartnerGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN места доставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'DeliveryPlaceGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'BuyerGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'SupplierGLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время поставки чч:мм
пришлось хранить строкой. иначе проблемы с xml', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'DeliveryTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата поставки
пришлось хранить строкой. иначе проблемы с xml', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'DeliveryDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата документа. гггг-мм-дд
пришлось хранить строкой. иначе проблемы с xml', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orders', @level2type = N'COLUMN', @level2name = N'DocNumber';

