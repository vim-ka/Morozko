CREATE TABLE [dbo].[messages_types] (
    [id]   INT           NOT NULL,
    [name] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

