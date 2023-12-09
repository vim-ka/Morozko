CREATE TABLE [dbo].[CommanCorrReason] (
    [ccID]     INT          IDENTITY (1, 1) NOT NULL,
    [ReasName] VARCHAR (80) NULL,
    UNIQUE NONCLUSTERED ([ccID] ASC)
);

