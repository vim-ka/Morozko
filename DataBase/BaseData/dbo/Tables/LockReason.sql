CREATE TABLE [dbo].[LockReason] (
    [lrID]   INT          IDENTITY (1, 1) NOT NULL,
    [lrName] VARCHAR (60) NULL,
    PRIMARY KEY CLUSTERED ([lrID] ASC)
);

