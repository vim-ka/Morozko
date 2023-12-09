CREATE TABLE [dbo].[MtAdvOrder] (
    [id]    INT IDENTITY (1, 1) NOT NULL,
    [ag_id] INT NULL,
    [hitag] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

