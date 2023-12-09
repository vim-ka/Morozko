CREATE TABLE [dbo].[NomenCat] (
    [NCID]    INT             IDENTITY (1, 1) NOT NULL,
    [CatName] VARCHAR (50)    NULL,
    [Koeff]   DECIMAL (10, 5) DEFAULT ((1)) NULL,
    [K_ICE]   TINYINT         DEFAULT ((0)) NULL,
    [K_PF]    TINYINT         DEFAULT ((0)) NULL,
    [K_Other] TINYINT         DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([NCID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 для прочего съедобного', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenCat', @level2type = N'COLUMN', @level2name = N'K_Other';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 для полуфабрикатов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenCat', @level2type = N'COLUMN', @level2name = N'K_PF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 для мороженого', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenCat', @level2type = N'COLUMN', @level2name = N'K_ICE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Исп. при расчете зарплаты.
Ожидаемый диапазон: 0.3-1.1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenCat', @level2type = N'COLUMN', @level2name = N'Koeff';

