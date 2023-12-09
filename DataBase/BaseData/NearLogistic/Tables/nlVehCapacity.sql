CREATE TABLE [NearLogistic].[nlVehCapacity] (
    [nlVehCapacityID] INT           NOT NULL,
    [Description]     VARCHAR (100) NULL,
    [WeightMin]       FLOAT (53)    NULL,
    [WeightMax]       FLOAT (53)    NULL,
    [VolMin]          FLOAT (53)    DEFAULT ((0)) NULL,
    [VolMax]          FLOAT (53)    NULL,
    [DescriptionVol]  VARCHAR (100) NULL,
    CONSTRAINT [PK__nlVehCap__F06EE83890768ED4] PRIMARY KEY CLUSTERED ([nlVehCapacityID] ASC)
);

