CREATE TABLE [NearLogistic].[distance] (
    [id_distance] INT IDENTITY (1, 1) NOT NULL,
    [pointA]      INT NOT NULL,
    [pointB]      INT NOT NULL,
    [distance]    INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__distance__B989238A32492218] PRIMARY KEY CLUSTERED ([id_distance] ASC)
);


GO
CREATE NONCLUSTERED INDEX [distance_idx2]
    ON [NearLogistic].[distance]([pointB] ASC);


GO
CREATE NONCLUSTERED INDEX [distance_idx1]
    ON [NearLogistic].[distance]([pointA] ASC);

