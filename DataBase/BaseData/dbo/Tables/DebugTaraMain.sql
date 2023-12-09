CREATE TABLE [dbo].[DebugTaraMain] (
    [tarid] INT      IDENTITY (1, 1) NOT NULL,
    [nd]    DATETIME NULL,
    [b_id]  INT      NULL,
    [sell1] INT      DEFAULT (0) NULL,
    [sell2] INT      DEFAULT (0) NULL,
    [sell3] INT      DEFAULT (0) NULL,
    [sell4] INT      DEFAULT (0) NULL,
    [Sell5] INT      DEFAULT (0) NULL,
    [Sell6] INT      DEFAULT (0) NULL,
    [Sell7] INT      DEFAULT (0) NULL,
    [Sell8] INT      DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([tarid] ASC)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[DebugTaraMain] TO PUBLIC
    AS [dbo];

