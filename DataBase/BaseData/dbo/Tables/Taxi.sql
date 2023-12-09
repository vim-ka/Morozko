CREATE TABLE [dbo].[Taxi] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [DateTrip]      DATETIME      NULL,
    [Time]          VARCHAR (5)   NULL,
    [Ticket]        INT           NOT NULL,
    [Way]           VARCHAR (100) NULL,
    [Sum]           INT           NULL,
    [TimeWait]      INT           NULL,
    [FIOMain]       VARCHAR (50)  NULL,
    [FIOCount]      INT           NULL,
    [FIO]           VARCHAR (50)  NULL,
    [Purpose]       VARCHAR (20)  NULL,
    [Additional]    VARCHAR (200) NULL,
    [DelFlag]       INT           CONSTRAINT [DF_Taxi_DelFlag] DEFAULT ((0)) NULL,
    [Department]    VARCHAR (20)  NULL,
    [Checked]       INT           NULL,
    [NoteCheck]     INT           NULL,
    [IntruderCheck] INT           NULL,
    [Average]       INT           NULL,
    [DepID]         INT           NULL,
    [PointStart]    VARCHAR (50)  DEFAULT ('Морозко') NULL,
    [PointArrival]  VARCHAR (50)  DEFAULT ('Морозко') NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([Ticket] ASC, [DateTrip] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Точка прибытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'PointArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Точка отправления', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'PointStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сверка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'IntruderCheck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'С замечаниями', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'NoteCheck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Проверено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Checked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению, заменен на DepID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Department';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'FIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'FIOCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'FIOMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время ожидания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'TimeWait';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Sum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'путь', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Way';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер билета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Ticket';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время поездки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата поездки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Taxi', @level2type = N'COLUMN', @level2name = N'DateTrip';

