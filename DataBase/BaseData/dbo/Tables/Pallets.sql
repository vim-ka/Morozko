CREATE TABLE [dbo].[Pallets] (
    [plID] INT IDENTITY (1, 1) NOT NULL,
    [ncom] INT NULL,
    [ptID] INT NULL,
    [tmID] INT NULL,
    CONSTRAINT [PK_Pallets_plID] PRIMARY KEY CLUSTERED ([plID] ASC)
);

