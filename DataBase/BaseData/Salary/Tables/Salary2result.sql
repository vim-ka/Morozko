CREATE TABLE [Salary].[Salary2result] (
    [s2id]     INT             NULL,
    [DepID]    INT             NULL,
    [DName]    VARCHAR (100)   NULL,
    [sv_id]    INT             NULL,
    [SuperFam] VARCHAR (100)   NULL,
    [ag_id]    INT             NULL,
    [AgentFam] VARCHAR (100)   NULL,
    [b_id]     INT             NULL,
    [dck]      INT             NULL,
    [gpName]   VARCHAR (100)   NULL,
    [Plata]    DECIMAL (15, 2) NULL,
    [Dohod]    DECIMAL (15, 2) NULL,
    [Kopl]     DECIMAL (15, 2) NULL,
    [Sell]     DECIMAL (15, 2) CONSTRAINT [DF__Salary2res__Sell__0393D2F5] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажа, т.е. оборот', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2result', @level2type = N'COLUMN', @level2name = N'Sell';

