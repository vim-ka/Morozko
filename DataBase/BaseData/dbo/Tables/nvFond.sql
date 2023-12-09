CREATE TABLE [dbo].[nvFond] (
    [NfID]      INT             IDENTITY (1, 1) NOT NULL,
    [Datnom]    BIGINT          NULL,
    [nvid]      INT             NULL,
    [NmID]      INT             NULL,
    [fgID]      INT             NULL,
    [FpID]      INT             NULL,
    [P_ID]      INT             NULL,
    [Delta]     INT             NULL,
    [flgWeight] BIT             DEFAULT ((0)) NULL,
    [EffWeight] DECIMAL (12, 3) NULL,
    PRIMARY KEY CLUSTERED ([NfID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nvfond_nvid_idx]
    ON [dbo].[nvFond]([nvid] ASC);


GO
CREATE NONCLUSTERED INDEX [nvfond_fpid_idx]
    ON [dbo].[nvFond]([FpID] ASC);


GO
CREATE NONCLUSTERED INDEX [nvfond_datnom_idx]
    ON [dbo].[nvFond]([Datnom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'В момент продажи это был весовой товар?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'flgWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма в копейках на единицу товара, часть от (BasePrice-Price)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'Delta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фонд (подотчетное лицо)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'P_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Строка в списке фондов finplan.FondParts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'FpID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Группа фондов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'fgID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер правила из Netspec2_Main', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'NmID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Строка в накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'nvid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Накладная', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'Datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'nvFond', @level2type = N'COLUMN', @level2name = N'NfID';

