CREATE TABLE [Statistics].[SCalc] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [idx_stat]  INT             NOT NULL,
    [kol]       NUMERIC (15, 2) NULL,
    [p_id]      INT             NULL,
    [date_from] DATETIME        NULL,
    [date_to]   DATETIME        NULL,
    [st_sum]    NUMERIC (18, 2) NULL,
    [kol_vs]    NUMERIC (15, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код статистики из таблицы Statistics.SStat', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SCalc', @level2type = N'COLUMN', @level2name = N'idx_stat';

