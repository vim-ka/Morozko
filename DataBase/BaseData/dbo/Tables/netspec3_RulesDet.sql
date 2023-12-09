CREATE TABLE [dbo].[netspec3_RulesDet] (
    [rdID]  INT             IDENTITY (1, 1) NOT NULL,
    [ruID]  INT             NOT NULL,
    [expID] INT             NOT NULL,
    [Rub]   DECIMAL (10, 4) NOT NULL,
    [Perc]  DECIMAL (10, 4) NULL,
    PRIMARY KEY CLUSTERED ([rdID] ASC)
);

