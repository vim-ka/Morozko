CREATE TABLE [db_FarLogistic].[dlCargoType] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [CargoType] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

