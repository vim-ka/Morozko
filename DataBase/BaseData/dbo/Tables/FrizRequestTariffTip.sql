CREATE TABLE [dbo].[FrizRequestTariffTip] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [name]      VARCHAR (256)   NULL,
    [baseprice] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [comment]   VARCHAR (512)   NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

