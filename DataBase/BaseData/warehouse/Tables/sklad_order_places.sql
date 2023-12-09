CREATE TABLE [warehouse].[sklad_order_places] (
    [sopID]  INT           IDENTITY (1, 1) NOT NULL,
    [datnom] INT           NOT NULL,
    [srid]   INT           NOT NULL,
    [places] INT           DEFAULT ((0)) NOT NULL,
    [dt]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [comp]   NVARCHAR (50) DEFAULT (host_name()) NOT NULL,
    PRIMARY KEY CLUSTERED ([sopID] ASC)
);

