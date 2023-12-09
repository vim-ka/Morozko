CREATE TABLE [dbo].[SertifVarRealiz] (
    [Id_var]     INT           IDENTITY (1, 1) NOT NULL,
    [Name_var]   VARCHAR (256) NULL,
    [Is_Del_Var] BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SERTIFVARREALIZ] PRIMARY KEY NONCLUSTERED ([Id_var] ASC)
);

