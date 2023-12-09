CREATE TABLE [dbo].[CoefСonvert] (
    [convId]    INT             NULL,
    [Hitag]     INT             NULL,
    [MeasId]    TINYINT         NULL,
    [mName]     VARCHAR (20)    NULL,
    [coef]      FLOAT (53)      NULL,
    [Weight_pr] NUMERIC (10, 3) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вес основной единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefСonvert', @level2type = N'COLUMN', @level2name = N'Weight_pr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'коэффициент перевода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefСonvert', @level2type = N'COLUMN', @level2name = N'coef';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование основной единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefСonvert', @level2type = N'COLUMN', @level2name = N'mName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код основной единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefСonvert', @level2type = N'COLUMN', @level2name = N'MeasId';

