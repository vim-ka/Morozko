CREATE TABLE [dbo].[BrNetFmt] (
    [Net]     INT          IDENTITY (0, 1) NOT NULL,
    [NetType] VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([Net] ASC)
);

