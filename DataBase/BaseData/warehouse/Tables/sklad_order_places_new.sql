CREATE TABLE [warehouse].[sklad_order_places_new] (
    [sopID]  INT           IDENTITY (1, 1) NOT NULL,
    [mhid]   INT           NOT NULL,
    [b_id]   INT           NOT NULL,
    [srid]   INT           NOT NULL,
    [places] INT           DEFAULT ((0)) NOT NULL,
    [dt]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [comp]   NVARCHAR (50) DEFAULT (host_name()) NOT NULL,
    PRIMARY KEY CLUSTERED ([sopID] ASC)
);

