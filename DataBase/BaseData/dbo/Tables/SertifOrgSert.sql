CREATE TABLE [dbo].[SertifOrgSert] (
    [Id_org]     INT           IDENTITY (1, 1) NOT NULL,
    [Name_org]   VARCHAR (256) NULL,
    [Is_Del_Org] BIT           DEFAULT ((0)) NOT NULL,
    [IdCity]     INT           NULL,
    CONSTRAINT [PK_SERTIFORGSERT] PRIMARY KEY NONCLUSTERED ([Id_org] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Справочник организаций сертификации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifOrgSert';

