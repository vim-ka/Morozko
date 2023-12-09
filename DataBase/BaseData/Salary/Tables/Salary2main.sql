CREATE TABLE [Salary].[Salary2main] (
    [s2id]      INT          IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME     DEFAULT (getdate()) NULL,
    [Day0]      DATETIME     NULL,
    [Day1]      DATETIME     NULL,
    [Cname]     VARCHAR (20) NULL,
    [Cancelled] BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([s2id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчет отменен?', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2main', @level2type = N'COLUMN', @level2name = N'Cancelled';

