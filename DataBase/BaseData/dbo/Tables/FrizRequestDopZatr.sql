CREATE TABLE [dbo].[FrizRequestDopZatr] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [frtt]      INT             DEFAULT ((1)) NOT NULL,
    [date_from] DATETIME        NULL,
    [date_to]   DATETIME        NULL,
    [kol]       INT             NULL,
    [price]     NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [frid]      INT             NULL,
    CONSTRAINT [FrizRequestDopZatr_fk] FOREIGN KEY ([frtt]) REFERENCES [dbo].[FrizRequestTariffTip] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на заявку на торговое оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequestDopZatr', @level2type = N'COLUMN', @level2name = N'frid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ключ из справочника с типами работ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequestDopZatr', @level2type = N'COLUMN', @level2name = N'frtt';

