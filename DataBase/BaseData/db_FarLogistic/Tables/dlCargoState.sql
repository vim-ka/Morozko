CREATE TABLE [db_FarLogistic].[dlCargoState] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [CargoState] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

