CREATE TABLE [dbo].[PrintOptions_copy] (
    [OurID]     SMALLINT     CONSTRAINT [DF__PrintOpti__OurID__35561712_copy] DEFAULT ((0)) NULL,
    [Pin]       INT          NULL,
    [Dck]       INT          NULL,
    [QtyNakl]   TINYINT      CONSTRAINT [DF__PrintOpti__QtyNa__0DE74436_copy] DEFAULT ((1)) NOT NULL,
    [QtyStf]    TINYINT      CONSTRAINT [DF__PrintOpti__QtySt__0EDB686F_copy] DEFAULT ((1)) NULL,
    [QtyTorg12] TINYINT      CONSTRAINT [DF__PrintOpti__QtyTo__2E5413C8_copy] DEFAULT ((1)) NULL,
    [QtyTtn]    TINYINT      CONSTRAINT [DF__PrintOpti__QtyTt__0FCF8CA8_copy] DEFAULT ((1)) NULL,
    [QtyBill]   TINYINT      CONSTRAINT [DF__PrintOpti__QtyBi__10C3B0E1_copy] DEFAULT ((0)) NULL,
    [QtyDover]  TINYINT      CONSTRAINT [DF__PrintOpti__QtyDo__11B7D51A_copy] DEFAULT ((0)) NULL,
    [StfBase]   VARCHAR (40) CONSTRAINT [DF__PrintOpti__StfBa__12ABF953_copy] DEFAULT ('') NULL,
    [Remark]    VARCHAR (60) NULL,
    [rec]       INT          IDENTITY (1, 1) NOT NULL,
    [QtyUPD]    TINYINT      CONSTRAINT [DF__PrintOpti__QtyUP__3C581A5C_copy] DEFAULT ((0)) NULL,
    [DCKVend]   INT          CONSTRAINT [DF__PrintOpti__DCKVe__5ADCA17C_copy] DEFAULT ((0)) NOT NULL,
    [Op]        INT          NULL,
    [QtyDover2] SMALLINT     DEFAULT ((0)) NULL,
    [DepID]     SMALLINT     DEFAULT ((-1)) NULL,
    CONSTRAINT [PrintOptions_pk_copy] PRIMARY KEY CLUSTERED ([rec] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrintOptions_uq]
    ON [dbo].[PrintOptions_copy]([Pin] ASC, [Dck] ASC, [OurID] ASC, [DCKVend] ASC, [DepID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Колич.довер.М-2:  0-нет,1..999-деньги, 1000..1999-товар,2000..2999-деньги+товар', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyDover2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор, который завел правило', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'DCKVend';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'колич. универсальных передаточных документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyUPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фраза в сч-факт., исп.в основании вместо № договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'StfBase';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Количество доверенностей старого типа.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyDover';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество счетов на оплату', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyBill';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество ТТН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyTtn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество ТОРГ-12', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyTorg12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество счет-фактур', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyStf';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество складских накладных, маленьких, в 3 частях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'QtyNakl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с покупателем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'Dck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Используется только для Pin=DCK=0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrintOptions_copy', @level2type = N'COLUMN', @level2name = N'OurID';

