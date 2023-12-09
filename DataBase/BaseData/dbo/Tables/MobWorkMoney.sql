CREATE TABLE [dbo].[MobWorkMoney] (
    [mwm]   INT       IDENTITY (1, 1) NOT NULL,
    [nd]    DATETIME  NULL,
    [ag_id] INT       NULL,
    [agent] CHAR (10) NULL,
    [pin]   INT       NULL,
    [sm]    MONEY     NULL,
    [dck]   INT       NULL,
    PRIMARY KEY CLUSTERED ([mwm] ASC)
);

