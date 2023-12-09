CREATE TABLE [dbo].[DrangLog] (
    [LdID]             INT           IDENTITY (1, 1) NOT NULL,
    [Act]              CHAR (3)      NULL,
    [nd]               DATETIME      CONSTRAINT [DF__DrangLog__nd__269B8162] DEFAULT (CONVERT([char](10),getdate(),(104))) NULL,
    [MarshND]          DATETIME      NULL,
    [tm]               CHAR (8)      CONSTRAINT [DF__DrangLog__tm__278FA59B] DEFAULT (CONVERT([char](8),getdate(),(108))) NULL,
    [datnom]           INT           DEFAULT ((0)) NULL,
    [SourMarsh]        INT           NULL,
    [DestMarsh]        INT           NULL,
    [SetAwayFlag]      BIT           CONSTRAINT [DF__DrangLog__SetAwa__1570F560] DEFAULT ((0)) NULL,
    [ResetAwayFlag]    BIT           CONSTRAINT [DF__DrangLog__ResetA__1EFA5F9A] DEFAULT ((0)) NULL,
    [MarshPrinted]     BIT           CONSTRAINT [DF__DrangLog__MarshP__16651999] DEFAULT ((0)) NULL,
    [RVZEPrinted]      BIT           CONSTRAINT [DF__DrangLog__RVZEPr__17593DD2] DEFAULT ((0)) NULL,
    [VedNabPrinted]    BIT           CONSTRAINT [DF__DrangLog__VedNab__184D620B] DEFAULT ((0)) NULL,
    [VedPogruzPrinted] BIT           CONSTRAINT [DF__DrangLog__VedPog__18034948] DEFAULT ((0)) NULL,
    [OplataDrvPrinted] BIT           CONSTRAINT [DF__DrangLog__Oplata__18F76D81] DEFAULT ((0)) NULL,
    [LgsID]            INT           DEFAULT ((0)) NOT NULL,
    [CompName]         VARCHAR (16)  NULL,
    [arrNnak]          VARCHAR (500) NULL,
    [op]               INT           NULL,
    PRIMARY KEY CLUSTERED ([LdID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Список №накл. для групповых операций', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'arrNnak';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Компьютер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'CompName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код логиста', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'LgsID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Печатался ли отчет "оплата водителю за рейc"?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'OplataDrvPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Напечатана ли погруз.ведомость?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'VedPogruzPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Напечатана ведомость набора?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'VedNabPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Напечатана раб.вед.зоны экспедиции?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'RVZEPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Напечатан маршрут?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'MarshPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сброшен флаг "В пути"?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'ResetAwayFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Установлен флаг "В пути"?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'SetAwayFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новый № маршр, не равен исходному для переброски накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'DestMarsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Исход.№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'SourMarsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'D/N накл (единственной или первой в списке)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'MarshND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'nd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код опер: ADD/PRN/MOV/SAF/RAF/PDO/NoZ/BME/BMI/PVO/EMH/EMW/EMD
Добав/Печать/Перемещ/УстAwayFlag/сбросAwayFlag/
Печать оптаты водителю/номер загрузки накл./
Экспорт в бизнес карту/импорт из бизнес карты/
Печать ведомости оплат/Изменения в маршруте/изменен веса/изменение кол-ва точек/', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'Act';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'порядковый № операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DrangLog', @level2type = N'COLUMN', @level2name = N'LdID';

