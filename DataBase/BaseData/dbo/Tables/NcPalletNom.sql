CREATE TABLE [dbo].[NcPalletNom] (
    [pnId]     INT        IDENTITY (1, 1) NOT NULL,
    [skg]      INT        NOT NULL,
    [DatNom]   INT        NOT NULL,
    [PalletNo] INT        NOT NULL,
    [Volum]    FLOAT (53) NOT NULL,
    PRIMARY KEY CLUSTERED ([pnId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'объем  на паллете', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NcPalletNom', @level2type = N'COLUMN', @level2name = N'Volum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ паллеты в складской группе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NcPalletNom', @level2type = N'COLUMN', @level2name = N'PalletNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'складская группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NcPalletNom', @level2type = N'COLUMN', @level2name = N'skg';

