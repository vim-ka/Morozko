CREATE TABLE [NearLogistic].[distance_history] (
    [id_distance] INT          IDENTITY (1, 1) NOT NULL,
    [pointA]      INT          NOT NULL,
    [pointB]      INT          NOT NULL,
    [distance]    INT          DEFAULT ((0)) NOT NULL,
    [dt_create]   DATETIME     DEFAULT (getdate()) NOT NULL,
    [host_create] VARCHAR (50) DEFAULT (host_name()) NOT NULL,
    [app_create]  VARCHAR (50) DEFAULT (app_name()) NULL,
    [UnloadID]    INT          NULL,
    [mhid]        INT          NULL,
    CONSTRAINT [PK__distance__B989238A7CE82842] PRIMARY KEY CLUSTERED ([id_distance] ASC)
);


GO
CREATE NONCLUSTERED INDEX [distance_history_idx2]
    ON [NearLogistic].[distance_history]([pointB] ASC);


GO
CREATE NONCLUSTERED INDEX [distance_history_idx1]
    ON [NearLogistic].[distance_history]([pointA] ASC);

