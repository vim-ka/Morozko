CREATE TABLE [RetroB].[BasTarget] (
    [btID]           INT             IDENTITY (1, 1) NOT NULL,
    [FondID]         INT             NOT NULL,
    [P_ID]           INT             NULL,
    [TargName]       VARCHAR (80)    NULL,
    [Remark]         VARCHAR (256)   NULL,
    [TargPerc]       DECIMAL (6, 2)  NULL,
    [TargCode]       INT             DEFAULT ((1)) NULL,
    [FondCase]       INT             DEFAULT ((-1)) NULL,
    [TargLimitSaldo] NUMERIC (15, 2) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([btID] ASC)
);

