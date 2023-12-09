CREATE TABLE [dbo].[MtOrderMess] (
    [MesID]     INT          IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME     NULL,
    [ID]        INT          NULL,
    [cSKU]      VARCHAR (50) NULL,
    [discAgent] VARCHAR (70) NULL,
    [discSuper] VARCHAR (50) NULL,
    [discChief] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([MesID] ASC),
    CONSTRAINT [MtOrderMess_uq] UNIQUE NONCLUSTERED ([ND] ASC, [ID] ASC)
);

