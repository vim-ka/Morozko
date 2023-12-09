CREATE TABLE [dbo].[Drivers] (
    [drId]           INT           IDENTITY (1, 1) NOT NULL,
    [Fio]            VARCHAR (100) NULL,
    [PaspNom]        VARCHAR (6)   NULL,
    [PaspSeries]     VARCHAR (4)   NULL,
    [PaspDateV]      DATETIME      NULL,
    [PaspV]          VARCHAR (100) NULL,
    [Phone]          VARCHAR (200) NOT NULL,
    [FuelCard]       VARCHAR (12)  NULL,
    [DriverDoc]      VARCHAR (12)  NULL,
    [trId]           INT           NULL,
    [V_id]           INT           DEFAULT ((0)) NULL,
    [Closed]         BIT           DEFAULT ((0)) NULL,
    [Sped]           BIT           DEFAULT ((0)) NULL,
    [BeginDate]      DATETIME      NULL,
    [P_id]           INT           CONSTRAINT [DF__Drivers__P_id__407B4EF6] DEFAULT ((0)) NOT NULL,
    [B_id]           INT           DEFAULT ((0)) NULL,
    [Disab]          BIT           DEFAULT ((0)) NULL,
    [LgstType]       TINYINT       DEFAULT ((0)) NULL,
    [nlPersonalRank] INT           NULL,
    [crID]           INT           DEFAULT ((7)) NOT NULL,
    [Phone1]         VARCHAR (200) NULL,
    CONSTRAINT [Drivers_pk] PRIMARY KEY CLUSTERED ([drId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Разряд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'nlPersonalRank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип логистики (0-прямая и 1-обратная)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'LgstType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Блокировка водителя (невозможно прикрепить на маршрут)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Disab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код как покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'B_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код подотчетного', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'P_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала работы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Водитель экспедитор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Sped';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'водитель закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код машины', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'V_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'должность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'trId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Водительское удостоверение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'DriverDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Топливная карта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'FuelCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон водителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кем выдан паспорт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'PaspV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Паспорт дата выдачи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'PaspDateV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Паспорт серия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'PaspSeries';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Паспорт №', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'PaspNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ФИО водителя Устаревшее - брать из Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers', @level2type = N'COLUMN', @level2name = N'Fio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица водителей', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Drivers';

