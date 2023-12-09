CREATE TABLE [dbo].[FReqTip] (
    [frt]    INT           IDENTITY (1, 1) NOT NULL,
    [ReqTip] VARCHAR (100) NULL,
    UNIQUE NONCLUSTERED ([frt] ASC)
);

