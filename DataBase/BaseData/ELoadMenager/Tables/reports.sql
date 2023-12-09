CREATE TABLE [ELoadMenager].[reports] (
    [object_id] INT             NOT NULL,
    [report]    VARBINARY (MAX) NOT NULL,
    CONSTRAINT [reports_uq] UNIQUE NONCLUSTERED ([object_id] ASC)
);

