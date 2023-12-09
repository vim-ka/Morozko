CREATE TABLE [dbo].[ResttSell] (
    [nd]         DATETIME        NULL,
    [DocNum]     VARCHAR (50)    NULL,
    [KodNomen]   VARCHAR (50)    NULL,
    [Nomenklat]  VARCHAR (150)   NULL,
    [Kolvo]      DECIMAL (15, 3) NULL,
    [Summa]      MONEY           NULL,
    [KodKlienta] VARCHAR (30)    NULL,
    [Klient]     VARCHAR (100)   NULL,
    [Adres]      VARCHAR (150)   NULL,
    [Manager]    VARCHAR (100)   NULL,
    [EdIzm]      VARCHAR (5)     NULL,
    [rsid]       INT             IDENTITY (1, 1) NOT NULL,
    [Hitag]      INT             NULL,
    CONSTRAINT [ResttSell_pk] PRIMARY KEY CLUSTERED ([rsid] ASC)
);

