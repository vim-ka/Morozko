CREATE TABLE [dbo].[AutoBank] (
    [IDb]     INT          IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME     NULL,
    [Code]    INT          NULL,
    [Tip]     SMALLINT     NULL,
    [Name]    VARCHAR (50) NULL,
    [Sum]     MONEY        NULL,
    [OP]      SMALLINT     NULL,
    [Bank_ID] INT          NULL,
    UNIQUE NONCLUSTERED ([IDb] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Банк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoBank', @level2type = N'COLUMN', @level2name = N'Bank_ID';

