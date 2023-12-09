CREATE TABLE [dbo].[SertifSubject] (
    [IdSub]    INT           IDENTITY (1, 1) NOT NULL,
    [NameSub]  VARCHAR (256) NULL,
    [IsDelSub] BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SertifSubject_IdSub] PRIMARY KEY CLUSTERED ([IdSub] ASC)
);

