CREATE TABLE [dbo].[FDistTrTemp] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [plannd] DATETIME        NULL,
    [dist]   NUMERIC (10, 2) NULL,
    [p_id]   INT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

