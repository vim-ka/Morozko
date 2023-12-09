CREATE TABLE [db_FarLogistic].[dlCalendar_log] (
    [IDDrv]         INT           NULL,
    [CalDate]       DATETIME      NULL,
    [CalendarState] INT           NULL,
    [Comment]       VARCHAR (500) NULL,
    [MarshID]       INT           NULL,
    [IDCalendarLog] INT           IDENTITY (1, 1) NOT NULL,
    [DateLog]       DATETIME      NULL,
    CONSTRAINT [dlCalendar_log_pk] PRIMARY KEY CLUSTERED ([IDCalendarLog] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'маршрут', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlCalendar_log', @level2type = N'COLUMN', @level2name = N'MarshID';

