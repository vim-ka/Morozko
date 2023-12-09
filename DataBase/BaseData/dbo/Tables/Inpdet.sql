CREATE TABLE [dbo].[Inpdet] (
    [nd]                DATETIME        NULL,
    [ncom]              INT             NULL,
    [id]                INT             NULL,
    [hitag]             INT             NULL,
    [price]             MONEY           NULL,
    [cost]              MONEY           NULL,
    [kol]               DECIMAL (10, 3) NULL,
    [sert_id]           INT             NULL,
    [minp]              INT             NULL,
    [mpu]               INT             NULL,
    [dater]             VARCHAR (20)    NULL,
    [srokh]             VARCHAR (20)    NULL,
    [nalog5]            NUMERIC (1)     NULL,
    [op]                SMALLINT        NULL,
    [country]           VARCHAR (15)    NULL,
    [sklad]             SMALLINT        NULL,
    [kol_b]             INT             NULL,
    [summacost]         MONEY           NULL,
    [BasePrice]         MONEY           DEFAULT (0) NULL,
    [inId]              INT             IDENTITY (1, 1) NOT NULL,
    [CountryID]         INT             NULL,
    [ProducerID]        INT             NULL,
    [weight]            DECIMAL (19, 3) NULL,
    [Id_vet_svid]       INT             NULL,
    [cost_delivery_1kg] DECIMAL (15, 2) DEFAULT ((0)) NOT NULL,
    [QTY]               DECIMAL (18, 4) DEFAULT ((0)) NULL,
    [unid]              INT             DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [Inpdet_pk] PRIMARY KEY CLUSTERED ([inId] ASC),
    CONSTRAINT [Inpdet_fk] FOREIGN KEY ([Id_vet_svid]) REFERENCES [dbo].[SertifVetSvid] ([Id_vet_svid]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [Inpdet_idx3]
    ON [dbo].[Inpdet]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [Inpdet_idx2]
    ON [dbo].[Inpdet]([nd] ASC, [id] ASC);


GO
CREATE NONCLUSTERED INDEX [Inpdet_idx]
    ON [dbo].[Inpdet]([nd] ASC, [ncom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код вет. свидетельства', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'Id_vet_svid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид производителя ссылка на Producer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'ProducerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид страны ссылка на Country', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'CountryID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'summacost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'sklad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К УДАЛЕНИЮ ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'country';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'срок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'srokh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата изг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'dater';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'МПУ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'mpu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'минП', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'minp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер сертефиката', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'sert_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количество', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'kol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код номенклатуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'ncom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Inpdet', @level2type = N'COLUMN', @level2name = N'nd';

