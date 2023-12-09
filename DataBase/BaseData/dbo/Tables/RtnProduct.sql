CREATE TABLE [dbo].[RtnProduct] (
    [rpId]      INT         IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME    CONSTRAINT [DF__RtnProduct__ND__5BC376B8] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [Tm]        VARCHAR (8) CONSTRAINT [DF__RtnProduct__Tm__58E70A0D] DEFAULT (CONVERT([varchar],getdate(),(8))) NULL,
    [DatNom]    INT         NULL,
    [RefDatNom] INT         NULL,
    [Plata]     MONEY       CONSTRAINT [DF__RtnProduc__Plata__57F2E5D4] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DatNom прямой накл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RtnProduct', @level2type = N'COLUMN', @level2name = N'RefDatNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DatNom возвратной накл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RtnProduct', @level2type = N'COLUMN', @level2name = N'DatNom';

