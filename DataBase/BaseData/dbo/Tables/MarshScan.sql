CREATE TABLE [dbo].[MarshScan] (
    [datnom]     INT      NOT NULL,
    [OpArc]      INT      NULL,
    [SavedArc]   DATETIME NULL,
    [OpSell]     INT      NULL,
    [SavedSell]  DATETIME NULL,
    [OpCheck]    INT      NULL,
    [SavedCheck] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([datnom] ASC)
);

