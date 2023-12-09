CREATE TABLE [ELoadMenager].[querys] (
    [object_id] INT            NOT NULL,
    [QueryText] VARCHAR (5000) NOT NULL,
    CONSTRAINT [querys_pk] PRIMARY KEY CLUSTERED ([object_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [querys_idx]
    ON [ELoadMenager].[querys]([object_id] ASC);

