CREATE TABLE [NearLogistic].[points] (
    [point_id] INT           IDENTITY (1, 1) NOT NULL,
    [adress]   VARCHAR (500) DEFAULT ('') NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__points__0241361313BE44EA]
    ON [NearLogistic].[points]([point_id] ASC);

