CREATE TABLE [dbo].[FTranspDet] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [tr_num] VARCHAR (20)    NULL,
    [nd]     DATETIME        NULL,
    [place]  VARCHAR (512)   NULL,
    [line]   INT             NULL,
    [class]  INT             NULL,
    [summa]  NUMERIC (12, 2) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на главную таблицу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FTranspDet', @level2type = N'COLUMN', @level2name = N'tr_num';

