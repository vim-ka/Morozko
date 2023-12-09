CREATE TABLE [dbo].[SertifNomenVetCat] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [Hitag]   INT      NULL,
    [IdCat]   INT      NULL,
    [Op]      INT      NULL,
    [DateCat] DATETIME NULL,
    [IsDEL]   BIT      DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SertifNomenVetCat_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

