CREATE TABLE [dbo].[BdPlan] (
    [BdNo]  INT         NOT NULL,
    [ND]    DATETIME    DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [Tm]    VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [OP]    INT         DEFAULT ((0)) NULL,
    [DepID] INT         NULL,
    [month] TINYINT     NULL,
    [year]  INT         NULL,
    [uin]   INT         NULL,
    UNIQUE NONCLUSTERED ([BdNo] ASC)
);

