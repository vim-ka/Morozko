CREATE TABLE [dbo].[DayCalendar] (
    [NDay]       INT      NOT NULL,
    [DATE]       DATETIME NOT NULL,
    [YEAR]       SMALLINT NOT NULL,
    [MONTH]      TINYINT  NOT NULL,
    [Week]       TINYINT  NOT NULL,
    [DayOfMonth] TINYINT  NOT NULL,
    [DayEnd]     DATETIME NOT NULL,
    [DayOfWeek]  TINYINT  NOT NULL,
    CONSTRAINT [PK_DayCalendar] PRIMARY KEY NONCLUSTERED ([NDay] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_year_month]
    ON [dbo].[DayCalendar]([YEAR] ASC, [MONTH] ASC)
    INCLUDE([DATE]);


GO
CREATE UNIQUE CLUSTERED INDEX [clst]
    ON [dbo].[DayCalendar]([DATE] ASC);


GO
CREATE TRIGGER [dbo].[IOI_DayCalendar] ON [dbo].[DayCalendar]
WITH EXECUTE AS CALLER
INSTEAD OF INSERT
AS
BEGIN
        SET NOCOUNT ON;
        INSERT INTO [DayCalendar] ([DATE], [YEAR], [MONTH], [Week], [DayOfMonth], [NDay], [DayEnd], [DayOfWeek]) 
        SELECT
                [DATE],
                DATEPART(YEAR, [DATE]), 
                DATEPART(MONTH, [DATE]), 
                DATEPART(week, [DATE]), 
                DATEPART(DAY, [DATE]),
                ROUND(CAST([DATE] AS FLOAT), 0),
                [DATE] + 1 - 3.858025E-08,
                DATEPART(WEEKDAY, [DATE])
        FROM inserted
END