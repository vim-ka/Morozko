CREATE TABLE [NearLogistic].[nlTariffType] (
    [ttID]       INT          IDENTITY (1, 1) NOT NULL,
    [TariffType] VARCHAR (50) NULL,
    [nal]        BIT          DEFAULT ((1)) NOT NULL,
    [SpedTariff] BIT          DEFAULT ((0)) NULL,
    [Clients]    BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__nlTariff__9CB9DF00DF284613] PRIMARY KEY CLUSTERED ([ttID] ASC)
);

