CREATE TABLE [dbo].[KsOper_old] (
    [Oper]     INT           NOT NULL,
    [OperName] VARCHAR (40)  NULL,
    [RashFlag] BIT           NULL,
    [LostFlag] BIT           NULL,
    [NewName]  VARCHAR (100) NULL,
    [NewOper]  INT           NULL,
    PRIMARY KEY CLUSTERED ([Oper] ASC)
);

