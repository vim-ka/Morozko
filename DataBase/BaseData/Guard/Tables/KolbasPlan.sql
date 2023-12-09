CREATE TABLE [Guard].[KolbasPlan] (
    [KpID]         INT      IDENTITY (1, 1) NOT NULL,
    [ND]           DATETIME NULL,
    [Ag_ID]        INT      NULL,
    [B_ID]         INT      NULL,
    [KolbasWeight] INT      NULL,
    PRIMARY KEY CLUSTERED ([KpID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [KolbasIndex]
    ON [Guard].[KolbasPlan]([ND] ASC, [Ag_ID] ASC, [B_ID] ASC);

