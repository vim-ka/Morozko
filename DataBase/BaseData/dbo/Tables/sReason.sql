CREATE TABLE [dbo].[sReason] (
    [ReasID] SMALLINT     NOT NULL,
    [RName]  VARCHAR (20) NULL,
    UNIQUE NONCLUSTERED ([ReasID] ASC)
);

