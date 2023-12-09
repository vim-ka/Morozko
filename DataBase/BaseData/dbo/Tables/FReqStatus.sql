CREATE TABLE [dbo].[FReqStatus] (
    [frs]     INT          NOT NULL,
    [FStatus] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([frs] ASC)
);

