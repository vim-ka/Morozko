CREATE TABLE [Statistics].[SCoeffLog] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [statid]   INT             NULL,
    [datefrom] DATETIME        NULL,
    [dateto]   DATETIME        NULL,
    [hi]       NUMERIC (12, 3) NULL,
    [lo]       NUMERIC (12, 3) NULL
);

