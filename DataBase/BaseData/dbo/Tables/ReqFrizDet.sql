CREATE TABLE [dbo].[ReqFrizDet] (
    [ReqFrDet] INT IDENTITY (1, 1) NOT NULL,
    [ReqFr]    INT NOT NULL,
    [Nom]      INT NOT NULL,
    UNIQUE NONCLUSTERED ([ReqFr] ASC)
);

