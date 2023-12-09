CREATE TABLE [dbo].[SertifVetCat] (
    [IdCat]    INT           IDENTITY (1, 1) NOT NULL,
    [NameCat]  VARCHAR (256) NULL,
    [IsDelCat] BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SertifVetCat_IdCat] PRIMARY KEY CLUSTERED ([IdCat] ASC)
);

