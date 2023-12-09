CREATE TABLE [dbo].[ncRash] (
    [datnom]       INT             NOT NULL,
    [BruttoWeight] DECIMAL (12, 3) NULL,
    [SaleDeps]     MONEY           NULL,
    [OtherDeps]    MONEY           NULL,
    PRIMARY KEY CLUSTERED ([datnom] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приведенный расход других подразделений', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ncRash', @level2type = N'COLUMN', @level2name = N'OtherDeps';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный расход добывающего подразделения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ncRash', @level2type = N'COLUMN', @level2name = N'SaleDeps';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и номер накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ncRash', @level2type = N'COLUMN', @level2name = N'datnom';

