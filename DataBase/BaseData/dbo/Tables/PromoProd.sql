CREATE TABLE [dbo].[PromoProd] (
    [id]          INT IDENTITY (1, 1) NOT NULL,
    [promoreq_id] INT NULL,
    [hitag]       INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

