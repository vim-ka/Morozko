CREATE TABLE [dbo].[SalaryLimits] (
    [week]    INT IDENTITY (1, 1) NOT NULL,
    [FoodLim] INT NULL,
    PRIMARY KEY CLUSTERED ([week] ASC)
);

