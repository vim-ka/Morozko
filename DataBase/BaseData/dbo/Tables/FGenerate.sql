CREATE TABLE [dbo].[FGenerate] (
    [pin]    INT             NULL,
    [gpname] VARCHAR (255)   NULL,
    [gpaddr] VARCHAR (255)   NULL,
    [rast]   NUMERIC (10, 2) NULL,
    [dd]     DATE            NULL,
    [reg_id] VARCHAR (5)     NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица для генерации маршрутов в программе ГСМ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FGenerate';

