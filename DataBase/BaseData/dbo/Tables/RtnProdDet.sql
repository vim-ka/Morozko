CREATE TABLE [dbo].[RtnProdDet] (
    [tid]       INT             IDENTITY (1, 1) NOT NULL,
    [DatNom]    INT             NULL,
    [RefDatNom] INT             NULL,
    [RefTekId]  INT             NULL,
    [TekId]     INT             NULL,
    [hitag]     INT             NULL,
    [kol_B]     INT             NULL,
    [Price]     MONEY           NULL,
    [Weight]    DECIMAL (10, 3) NULL,
    CONSTRAINT [RtnProdDet_pk] PRIMARY KEY CLUSTERED ([tid] ASC)
);

