CREATE TABLE [Guard].[AutoSMSLog] (
    [nd]    DATETIME      DEFAULT ([dbo].[today]()) NULL,
    [tm]    VARCHAR (8)   DEFAULT (CONVERT([char](8),CONVERT([varchar],getdate(),(8)),0)) NULL,
    [ag_id] INT           NULL,
    [pin]   INT           NULL,
    [phone] VARCHAR (12)  NULL,
    [mess]  VARCHAR (300) NULL
);

