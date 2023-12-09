CREATE TABLE [RetroB].[BasPricesMain] (
    [BPMid]   INT           IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME      DEFAULT ([dbo].[today]()) NULL,
    [TM]      CHAR (8)      DEFAULT ([dbo].[gettime]()) NULL,
    [OP]      INT           NULL,
    [Actual]  BIT           NULL,
    [BPMName] VARCHAR (100) NULL,
    UNIQUE NONCLUSTERED ([BPMid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [BasPricesMain_idx2]
    ON [RetroB].[BasPricesMain]([OP] ASC);


GO
CREATE NONCLUSTERED INDEX [BasPricesMain_idx]
    ON [RetroB].[BasPricesMain]([ND] ASC);

