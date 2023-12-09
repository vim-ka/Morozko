CREATE TABLE [dbo].[FFuelDepLimit] (
    [fid]    INT      IDENTITY (1, 1) NOT NULL,
    [fdepid] INT      NULL,
    [fplan]  INT      NULL,
    [ffact]  INT      NULL,
    [fdate]  DATETIME NULL,
    UNIQUE NONCLUSTERED ([fid] ASC)
);

