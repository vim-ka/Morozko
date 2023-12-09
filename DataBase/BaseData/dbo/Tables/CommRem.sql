CREATE TABLE [dbo].[CommRem] (
    [ID]          INT      IDENTITY (1, 1) NOT NULL,
    [ND]          DATETIME DEFAULT (getdate()) NULL,
    [StartRemove] MONEY    NULL,
    [EndRemove]   MONEY    NULL,
    [NCOM]        INT      NULL,
    UNIQUE NONCLUSTERED ([ID] ASC)
);

