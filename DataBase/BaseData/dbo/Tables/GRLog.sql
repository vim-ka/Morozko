CREATE TABLE [dbo].[GRLog] (
    [Ngrp]               INT           NULL,
    [GrpName]            VARCHAR (50)  NULL,
    [Vet]                BIT           DEFAULT ((0)) NULL,
    [Parent]             INT           CONSTRAINT [DF__GRLog__Parent__04B2DFB7] DEFAULT ((0)) NULL,
    [Category]           INT           DEFAULT ((1)) NULL,
    [MainParent]         INT           DEFAULT ((0)) NULL,
    [Levl]               INT           DEFAULT ((0)) NULL,
    [Prior]              CHAR (2)      NULL,
    [Cost1kgStor]        MONEY         NULL,
    [Cost1kgDeliv]       MONEY         NULL,
    [nlMt]               INT           NULL,
    [AgInvis]            BIT           DEFAULT ((0)) NULL,
    [IsDel]              BIT           CONSTRAINT [DF__GRLog__IsDel__097794D4] DEFAULT ((0)) NULL,
    [OP]                 INT           CONSTRAINT [DF__GRLog__OP__0A6BB90D] DEFAULT ((0)) NULL,
    [IDLog]              INT           IDENTITY (1, 1) NOT NULL,
    [DateTimeLog]        DATETIME      DEFAULT (getdate()) NULL,
    [CompNameLog]        VARCHAR (100) DEFAULT (host_name()) NULL,
    [ActTypeLog]         INT           NULL,
    [ApplicationNameLog] VARCHAR (100) DEFAULT (app_name()) NULL,
    CONSTRAINT [GRLog_pk] PRIMARY KEY CLUSTERED ([IDLog] ASC)
);


GO
CREATE NONCLUSTERED INDEX [MainGR_idx]
    ON [dbo].[GRLog]([MainParent] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип операции
1-вставка
2-изменение
3-удаление', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'ActTypeLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'последний пользователь', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'удалено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'IsDel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скрыта от агентов ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'AgInvis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на [NearLogistic] nlMassType (Расчет массы в рейсе)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'nlMt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость доставки 1 кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'Cost1kgDeliv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость хранения 1 кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'Cost1kgStor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'уровень вложенности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'Levl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Старший предок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRLog', @level2type = N'COLUMN', @level2name = N'MainParent';

