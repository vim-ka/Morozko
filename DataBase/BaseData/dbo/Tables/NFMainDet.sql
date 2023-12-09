CREATE TABLE [dbo].[NFMainDet] (
    [id]      INT IDENTITY (1, 1) NOT NULL,
    [main_id] INT NULL,
    CONSTRAINT [NFMainDet_fk] FOREIGN KEY ([main_id]) REFERENCES [dbo].[NFMain] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);

