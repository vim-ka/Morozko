CREATE TABLE [dbo].[UsrTaxi] (
    [Id]  INT          IDENTITY (1, 1) NOT NULL,
    [Fio] VARCHAR (50) NULL,
    CONSTRAINT [PK_UsrTaxi] PRIMARY KEY CLUSTERED ([Id] ASC)
);

