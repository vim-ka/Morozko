CREATE TABLE [Guard].[VirtDef] (
    [pin]    INT           IDENTITY (1, 1) NOT NULL,
    [Name]   VARCHAR (150) NULL,
    [GpAddr] VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([pin] ASC)
);

