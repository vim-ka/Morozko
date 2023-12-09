CREATE TABLE [Guard].[Tasks] (
    [tsID]      INT           IDENTITY (1, 1) NOT NULL,
    [Name]      VARCHAR (100) NULL,
    [DayCreate] DATETIME      NULL,
    [Day0]      DATETIME      NULL,
    [Day1]      DATETIME      NULL,
    [Remark]    VARCHAR (100) NULL,
    [DepID]     INT           NULL,
    [Ag_id]     INT           NULL,
    [Active]    BIT           DEFAULT ((0)) NULL,
    [SKU]       INT           NULL,
    [Code]      INT           NULL,
    [CodeTip]   SMALLINT      NULL,
    PRIMARY KEY CLUSTERED ([tsID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 если Code-код товара,1-поставщика', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'Tasks', @level2type = N'COLUMN', @level2name = N'CodeTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара или поставщика', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'Tasks', @level2type = N'COLUMN', @level2name = N'Code';

