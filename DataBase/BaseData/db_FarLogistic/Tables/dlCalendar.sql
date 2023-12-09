CREATE TABLE [db_FarLogistic].[dlCalendar] (
    [IDDrv]           INT           NULL,
    [CalDate]         DATETIME      NULL,
    [CalendarState]   INT           NULL,
    [Comment]         VARCHAR (500) NULL,
    [MarshID]         INT           NULL,
    [IDCalendarEvent] INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [dlCalendar_pk] PRIMARY KEY CLUSTERED ([IDCalendarEvent] ASC)
);


GO
CREATE TRIGGER [db_FarLogistic].[dlCalendar_trd] ON [db_FarLogistic].[dlCalendar]
WITH EXECUTE AS CALLER
FOR DELETE
AS
insert into db_FarLogistic.dlCalendar_log(IDDrv,CalDate,CalendarState,Comment,MarshID,DateLog)
select d.IDDrv,d.CalDate,d.CalendarState,d.Comment,d.MarshID,getdate() from deleted d
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'маршрут', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlCalendar', @level2type = N'COLUMN', @level2name = N'MarshID';

