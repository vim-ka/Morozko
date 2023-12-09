CREATE TABLE [dbo].[FrizContract] (
    [ContractID] INT         IDENTITY (1, 1) NOT NULL,
    [ContractNo] INT         NULL,
    [DopContrNo] INT         NULL,
    [ND]         DATETIME    NULL,
    [Tm]         VARCHAR (8) NULL,
    [B_ID]       INT         NULL,
    [Our_ID]     SMALLINT    NULL,
    [OP]         INT         NULL,
    [Srok]       INT         NULL,
    [NDBeg]      DATETIME    NULL,
    [NDClose]    DATETIME    NULL,
    [AgrID]      INT         NULL,
    [CTip]       TINYINT     CONSTRAINT [DF__FrizContra__CTip__57BEA701] DEFAULT ((0)) NOT NULL,
    [DCK]        INT         DEFAULT ((0)) NULL,
    [NestNo]     INT         NULL,
    [MorozNo]    INT         NULL,
    CONSTRAINT [PK_FRIZCONTRACT] PRIMARY KEY CLUSTERED ([ContractID] ASC),
    CONSTRAINT [FrizContract_fk] FOREIGN KEY ([CTip]) REFERENCES [dbo].[FrizContractTip] ([CTip]) ON UPDATE CASCADE,
    CONSTRAINT [FrizContract_uq] UNIQUE NONCLUSTERED ([ContractNo] ASC, [DopContrNo] ASC)
);


GO
ALTER TABLE [dbo].[FrizContract] NOCHECK CONSTRAINT [FrizContract_fk];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора Морозко', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'MorozNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора Nestle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'NestNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'CTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'AgrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'NDClose';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доп. соглашение номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'DopContrNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizContract', @level2type = N'COLUMN', @level2name = N'ContractNo';

