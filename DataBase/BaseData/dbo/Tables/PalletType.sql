CREATE TABLE [dbo].[PalletType] (
    [ptID]   INT          IDENTITY (1, 1) NOT NULL,
    [ptName] VARCHAR (50) NULL,
    CONSTRAINT [PK_PalletType_ptID] PRIMARY KEY CLUSTERED ([ptID] ASC)
);

