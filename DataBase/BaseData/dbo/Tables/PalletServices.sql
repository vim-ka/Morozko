CREATE TABLE [dbo].[PalletServices] (
    [psID] INT IDENTITY (1, 1) NOT NULL,
    [plID] INT NULL,
    [stID] INT NULL,
    [qty]  INT NULL,
    CONSTRAINT [PK_PalletServices_psID] PRIMARY KEY CLUSTERED ([psID] ASC)
);

