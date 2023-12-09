CREATE TABLE [ELoadMenager].[headers] (
    [object_id] INT          NOT NULL,
    [id]        INT          NOT NULL,
    [caption]   VARCHAR (15) DEFAULT ('') NOT NULL,
    CONSTRAINT [headers_uq] UNIQUE NONCLUSTERED ([object_id] ASC, [id] ASC)
);

