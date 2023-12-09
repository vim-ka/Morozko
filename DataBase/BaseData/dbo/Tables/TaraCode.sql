CREATE TABLE [dbo].[TaraCode] (
    [TaraTag]   INT           NULL,
    [FishTag]   VARCHAR (254) NULL,
    [TaraTip]   TINYINT       NOT NULL,
    [TaraName]  VARCHAR (30)  NULL,
    [TaraPrice] MONEY         CONSTRAINT [DF__TaraCode__TaraPr__4C364F0E] DEFAULT (0.0) NULL,
    CONSTRAINT [TaraCode_pk] PRIMARY KEY CLUSTERED ([TaraTip] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode', @level2type = N'COLUMN', @level2name = N'TaraPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode', @level2type = N'COLUMN', @level2name = N'TaraName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode', @level2type = N'COLUMN', @level2name = N'TaraTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид номенклатуры куда прицепляем тару', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode', @level2type = N'COLUMN', @level2name = N'FishTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraCode', @level2type = N'COLUMN', @level2name = N'TaraTag';

