CREATE TABLE [NearLogistic].[delivery_plan] (
    [dpID]         INT           IDENTITY (1, 1) NOT NULL,
    [dt_create]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [comp]         VARCHAR (100) DEFAULT (host_name()) NOT NULL,
    [op]           INT           NOT NULL,
    [remark]       VARCHAR (500) NULL,
    [isdel]        BIT           DEFAULT ((0)) NOT NULL,
    [marsh_number] INT           DEFAULT ((0)) NOT NULL,
    [casher_id]    INT           NOT NULL,
    [point_id]     INT           NOT NULL,
    [delivery_day] INT           DEFAULT ((0)) NOT NULL,
    [day_periodic] INT           DEFAULT ((0)) NOT NULL
);

