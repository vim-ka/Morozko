CREATE TABLE [dbo].[FirmsKKM] (
    [Id]     INT IDENTITY (1, 1) NOT NULL,
    [IdFirm] INT NULL,
    [IdKKM]  INT NULL,
    CONSTRAINT [PK_FirmsKKM_IdFirms] PRIMARY KEY CLUSTERED ([Id] ASC)
);

