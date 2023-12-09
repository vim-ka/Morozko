CREATE TABLE [Guard].[ChainDet] (
    [CdID] INT IDENTITY (1, 1) NOT NULL,
    [ChID] INT NOT NULL,
    [DCK]  INT NULL,
    PRIMARY KEY CLUSTERED ([CdID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ChainDet_idx]
    ON [Guard].[ChainDet]([DCK] ASC);

