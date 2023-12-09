CREATE TABLE [dbo].[SertifVetOrder] (
    [IdOrd]        INT          IDENTITY (1, 1) NOT NULL,
    [NOrd]         VARCHAR (50) NULL,
    [DateOrd]      DATETIME     NULL,
    [IsDelOrd]     BIT          DEFAULT ((0)) NOT NULL,
    [DateOrdBegin] DATETIME     NULL,
    [DateOrdEnd]   DATETIME     NULL,
    CONSTRAINT [PK_SertifVetOrder_IdOrd] PRIMARY KEY CLUSTERED ([IdOrd] ASC)
);

