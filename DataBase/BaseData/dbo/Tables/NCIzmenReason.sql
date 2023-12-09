CREATE TABLE [dbo].[NCIzmenReason] (
    [nrID]     INT          IDENTITY (1, 1) NOT NULL,
    [ReasName] VARCHAR (80) NULL,
    UNIQUE NONCLUSTERED ([nrID] ASC)
);

