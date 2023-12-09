CREATE TABLE [Guard].[NotifyDebReestr] (
    [ndrid]   INT             IDENTITY (1, 1) NOT NULL,
    [nd]      DATETIME        DEFAULT ([dbo].[today]()) NULL,
    [dck]     INT             NULL,
    [Overdue] DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([ndrid] ASC)
);

