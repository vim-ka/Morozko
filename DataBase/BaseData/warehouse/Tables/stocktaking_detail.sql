CREATE TABLE [warehouse].[stocktaking_detail] (
    [stdID]         INT             IDENTITY (1, 1) NOT NULL,
    [stocktakingID] INT             NOT NULL,
    [hitag]         INT             NOT NULL,
    [sklad]         INT             NOT NULL,
    [qty]           INT             DEFAULT ((0)) NOT NULL,
    [mass]          DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [cost]          DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [Calculated]    BIT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([stdID] ASC)
);

