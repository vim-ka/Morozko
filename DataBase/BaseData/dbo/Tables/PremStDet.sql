CREATE TABLE [dbo].[PremStDet] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [st_id]  INT             NULL,
    [p_id]   INT             NULL,
    [dfrom]  DATETIME        NULL,
    [dto]    DATETIME        NULL,
    [summa]  NUMERIC (12, 3) NULL,
    [reqnum] INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на код заявки на премию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremStDet', @level2type = N'COLUMN', @level2name = N'reqnum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма по строке начисления', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremStDet', @level2type = N'COLUMN', @level2name = N'summa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код сотрудника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremStDet', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код статьи для начисления премии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremStDet', @level2type = N'COLUMN', @level2name = N'st_id';

