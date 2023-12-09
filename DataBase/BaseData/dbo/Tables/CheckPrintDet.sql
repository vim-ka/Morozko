CREATE TABLE [dbo].[CheckPrintDet] (
    [CPDID] INT             IDENTITY (1, 1) NOT NULL,
    [CpID]  INT             NOT NULL,
    [Hitag] INT             NULL,
    [Qty]   DECIMAL (13, 6) NULL,
    [Price] DECIMAL (10, 2) NULL,
    [NDS]   SMALLINT        NULL,
    [NvId]  INT             NULL,
    [TekID] INT             NULL,
    PRIMARY KEY CLUSTERED ([CPDID] ASC)
);

