CREATE TABLE [dbo].[return_quality] (
    [rqID]   INT          IDENTITY (1, 1) NOT NULL,
    [rqName] VARCHAR (50) NOT NULL,
    UNIQUE NONCLUSTERED ([rqID] ASC)
);

