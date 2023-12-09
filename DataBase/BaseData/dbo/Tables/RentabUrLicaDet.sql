CREATE TABLE [dbo].[RentabUrLicaDet] (
    [id]      INT IDENTITY (1, 1) NOT NULL,
    [ruid]    INT NULL,
    [ncod]    INT NULL,
    [calctip] INT NULL,
    CONSTRAINT [RentabUrLicaDet_fk] FOREIGN KEY ([ruid]) REFERENCES [dbo].[RentabUrLica] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);

