CREATE TABLE [dbo].[SertifOtvPers] (
    [Id_Otv]     INT           IDENTITY (1, 1) NOT NULL,
    [Name_otv]   VARCHAR (256) NULL,
    [Is_Del_Otv] BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SERTIFOTVPERS] PRIMARY KEY NONCLUSTERED ([Id_Otv] ASC)
);

