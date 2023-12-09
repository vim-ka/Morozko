CREATE TABLE [VanSell].[taskdet] (
    [tdid]         INT             IDENTITY (1, 1) NOT NULL,
    [taskid]       INT             NOT NULL,
    [hitag]        INT             NOT NULL,
    [name]         VARCHAR (100)   NULL,
    [minp]         INT             DEFAULT ((1)) NULL,
    [price]        NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [kol]          INT             DEFAULT ((0)) NULL,
    [tekid]        INT             DEFAULT ((-1)) NULL,
    [sell]         INT             DEFAULT ((0)) NULL,
    [nds]          INT             DEFAULT ((0)) NULL,
    [netto]        NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [brutto]       NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [country_name] VARCHAR (50)    DEFAULT ('Россия') NULL,
    [country_id]   INT             DEFAULT ((643)) NULL,
    [gtd]          VARCHAR (23)    NULL,
    UNIQUE NONCLUSTERED ([tdid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Товары, продажи, taskid - ссылка на таблицу заданий (task), tekid только для основной БД', @level0type = N'SCHEMA', @level0name = N'VanSell', @level1type = N'TABLE', @level1name = N'taskdet';

