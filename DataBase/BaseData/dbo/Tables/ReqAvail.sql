CREATE TABLE [dbo].[ReqAvail] (
    [reqAv]   SMALLINT     NOT NULL,
    [Comment] VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([reqAv] ASC)
);

