CREATE TABLE [dbo].[SertifCity] (
    [IdCity]    INT          IDENTITY (1, 1) NOT NULL,
    [NameCity]  VARCHAR (50) NULL,
    [IsDelCity] BIT          DEFAULT ((0)) NOT NULL,
    [IdSub]     INT          NULL,
    CONSTRAINT [PK_SertifCity_IdCity] PRIMARY KEY CLUSTERED ([IdCity] ASC)
);

