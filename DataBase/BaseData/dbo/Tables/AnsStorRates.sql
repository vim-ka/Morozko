CREATE TABLE [dbo].[AnsStorRates] (
    [ast]      INT        IDENTITY (1, 1) NOT NULL,
    [DCKVend]  INT        NULL,
    [DCKBuyer] INT        NULL,
    [NDS]      BIT        NULL,
    [rate]     FLOAT (53) NULL,
    UNIQUE NONCLUSTERED ([ast] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ставка в %', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnsStorRates', @level2type = N'COLUMN', @level2name = N'rate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnsStorRates', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnsStorRates', @level2type = N'COLUMN', @level2name = N'DCKBuyer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поставщик ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnsStorRates', @level2type = N'COLUMN', @level2name = N'DCKVend';

