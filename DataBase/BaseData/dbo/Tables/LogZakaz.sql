﻿CREATE TABLE [dbo].[LogZakaz] (
    [zid]               INT            IDENTITY (1, 1) NOT NULL,
    [ND]                DATETIME       DEFAULT ([dbo].[today]()) NULL,
    [TM]                VARCHAR (8)    DEFAULT ([dbo].[time]()) NULL,
    [CompName]          VARCHAR (30)   NOT NULL,
    [hitag]             INT            NULL,
    [tekid]             INT            NULL,
    [Qty]               FLOAT (53)     NULL,
    [Price]             MONEY          NULL,
    [Sklad]             SMALLINT       NULL,
    [EffWeight]         FLOAT (53)     NULL,
    [Cost]              MONEY          NULL,
    [Nds]               INT            NULL,
    [DelivGroup]        INT            DEFAULT ((0)) NULL,
    [MainExtra]         DECIMAL (7, 2) DEFAULT ((0.0)) NULL,
    [StfNom]            VARCHAR (17)   DEFAULT ('') NULL,
    [StfDate]           DATETIME       NULL,
    [NvID]              INT            DEFAULT ((0)) NULL,
    [RefTekId]          INT            DEFAULT ((0)) NULL,
    [Ag_Id]             INT            NULL,
    [B_ID]              INT            NULL,
    [OrdStick]          BIT            DEFAULT ((0)) NULL,
    [DCK]               INT            DEFAULT ((0)) NULL,
    [DocNom]            VARCHAR (20)   DEFAULT ('') NULL,
    [DocDate]           DATETIME       NULL,
    [ForcedIntegerSell] BIT            CONSTRAINT [DF__Zakaz__ForcedInt__7B745997_copy] DEFAULT ((0)) NOT NULL,
    [RefDatnom]         BIGINT         NULL,
    PRIMARY KEY CLUSTERED ([zid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Zakaz_idx]
    ON [dbo].[LogZakaz]([CompName] ASC);


GO
CREATE NONCLUSTERED INDEX [Zakaz_idx2]
    ON [dbo].[LogZakaz]([tekid] ASC);


GO
CREATE NONCLUSTERED INDEX [Zakaz_idx3]
    ON [dbo].[LogZakaz]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [Zakaz_idx4]
    ON [dbo].[LogZakaz]([RefTekId] ASC);


GO
CREATE NONCLUSTERED INDEX [Zakaz_idx5]
    ON [dbo].[LogZakaz]([B_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Принудительная продажа в штуках (даже для весового склада)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'ForcedIntegerSell';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'DocDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер входящего документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'DocNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак прилипания. 1-дозаказ.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'OrdStick';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'B_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Агент, кто сбросил заказ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'Ag_Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tekid в исходной накладной, нужен для возврата за вчера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'RefTekId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Исп.при возврате, ссылка на исх.продажу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'NvID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата счет фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'StfDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер счет-фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'StfNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скидка в заголовке накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'MainExtra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogZakaz', @level2type = N'COLUMN', @level2name = N'DelivGroup';

