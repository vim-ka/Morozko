CREATE TABLE [dbo].[PrintNcParams] (
    [pnpID]  INT      IDENTITY (1, 1) NOT NULL,
    [Datnom] INT      NULL,
    [pdType] SMALLINT NULL,
    [Qty]    TINYINT  NULL,
    PRIMARY KEY CLUSTERED ([pnpID] ASC)
);

