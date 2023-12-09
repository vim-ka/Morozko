CREATE TABLE [warehouse].[skladreg] (
    [sregionID] INT         IDENTITY (1, 1) NOT NULL,
    [sregName]  VARCHAR (5) NOT NULL,
    [priority]  INT         DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([sregionID] ASC)
);

