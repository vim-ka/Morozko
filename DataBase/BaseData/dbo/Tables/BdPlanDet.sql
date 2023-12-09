CREATE TABLE [dbo].[BdPlanDet] (
    [BdPID]  INT           IDENTITY (1, 1) NOT NULL,
    [BdNo]   INT           NULL,
    [Oper]   INT           NULL,
    [Remark] VARCHAR (150) NULL,
    [Contr]  VARCHAR (100) NULL,
    [Sm]     MONEY         NULL,
    [Tip]    CHAR (3)      NULL,
    [PlanND] DATETIME      NULL,
    [DepID]  INT           NULL,
    [tp]     INT           NULL,
    CONSTRAINT [BdPlanDet_fk] FOREIGN KEY ([BdNo]) REFERENCES [dbo].[BdPlan] ([BdNo]) ON UPDATE CASCADE,
    CONSTRAINT [BdPlanDet_fk2] FOREIGN KEY ([Oper]) REFERENCES [dbo].[KsOper] ([Oper]) ON UPDATE CASCADE,
    CONSTRAINT [BdPlanDet_fk3] FOREIGN KEY ([tp]) REFERENCES [dbo].[BdTipPlat] ([tp]) ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([BdPID] ASC)
);

