CREATE TABLE [dbo].[LogWork] (
    [LogWorkID] INT           IDENTITY (1, 1) NOT NULL,
    [Operator]  INT           NULL,
    [ND]        DATETIME      DEFAULT (dateadd(day,(0),datediff(day,(0),getdate()))) NULL,
    [NumberNC]  VARCHAR (300) NULL,
    [CountDoc]  INT           NULL,
    [TypeWork]  VARCHAR (35)  NULL,
    [TM]        VARCHAR (8)   DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    PRIMARY KEY CLUSTERED ([LogWorkID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'TM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип работы(печать, изменение, добавление)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'TypeWork';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Колво документов прикрепленных', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'CountDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер накл или список номеров накл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'NumberNC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork', @level2type = N'COLUMN', @level2name = N'Operator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сертификация W8 отчет о работе сотрудников(пока только Першина)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogWork';

