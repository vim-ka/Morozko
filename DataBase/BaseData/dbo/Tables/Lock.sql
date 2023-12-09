CREATE TABLE [dbo].[Lock] (
    [LockID]      INT           IDENTITY (1, 1) NOT NULL,
    [LockComment] NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([LockID] ASC)
);

