CREATE TABLE [dbo].[TaraCode2] (
    [FishTag]   INT     NOT NULL,
    [TaraTag]   INT     CONSTRAINT [DF__TaraCode2__TaraT__253C7D7E] DEFAULT (0) NULL,
    [TaraTip]   TINYINT CONSTRAINT [DF__TaraCode2__TaraT__24485945] DEFAULT (0) NULL,
    [TaraPrice] MONEY   CONSTRAINT [DF__TaraCode2__TaraP__2630A1B7] DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([FishTag] ASC),
    CONSTRAINT [TaraCode2_uq] UNIQUE NONCLUSTERED ([FishTag] ASC, [TaraTag] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode2', @level2type = N'COLUMN', @level2name = N'TaraPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на ид TaraCode', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode2', @level2type = N'COLUMN', @level2name = N'TaraTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код тары в Nomen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode2', @level2type = N'COLUMN', @level2name = N'TaraTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код номенклатуры в Nomen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode2', @level2type = N'COLUMN', @level2name = N'FishTag';

