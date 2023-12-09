CREATE TABLE [dbo].[DailyDiscard] (
    [ND]     DATETIME DEFAULT (CONVERT([varchar](10),getdate(),(112))) NULL,
    [TM]     CHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [tekid]  INT      NULL,
    [OP]     INT      NULL,
    [Qty]    INT      NULL,
    [Datnom] INT      NULL
);

