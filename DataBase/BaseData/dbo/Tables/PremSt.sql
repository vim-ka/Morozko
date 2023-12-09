CREATE TABLE [dbo].[PremSt] (
    [id]       INT           IDENTITY (1, 1) NOT NULL,
    [name]     VARCHAR (255) NULL,
    [iscalc]   BIT           DEFAULT ((0)) NULL,
    [linkcalc] INT           NULL,
    [isproc]   BIT           DEFAULT ((0)) NULL,
    [issum]    BIT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица-классификатор видов строк для начисления премий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremSt';

