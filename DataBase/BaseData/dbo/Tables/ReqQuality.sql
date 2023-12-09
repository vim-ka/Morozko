CREATE TABLE [dbo].[ReqQuality] (
    [rql]    SMALLINT     IDENTITY (1, 1) NOT NULL,
    [RQName] VARCHAR (15) NULL,
    UNIQUE NONCLUSTERED ([rql] ASC)
);

