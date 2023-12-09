CREATE TABLE [dbo].[KadryReason] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

