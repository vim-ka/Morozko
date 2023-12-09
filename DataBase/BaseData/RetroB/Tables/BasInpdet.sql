CREATE TABLE [RetroB].[BasInpdet] (
    [StartId]      INT             NOT NULL,
    [prID]         INT             NOT NULL,
    [BaseCost]     MONEY           NOT NULL,
    [FinalCost]    MONEY           NULL,
    [FinalCost1kg] DECIMAL (15, 5) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([StartId] ASC)
);

