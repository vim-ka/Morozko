CREATE TABLE [Statistics].[SCoeffBase] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [depid]     INT             NULL,
    [basevalue] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [datefrom]  DATETIME        NULL,
    [dateto]    DATETIME        NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

