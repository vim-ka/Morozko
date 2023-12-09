CREATE TABLE [NearLogistic].[nlTariffs] (
    [nlTariffsID] INT           IDENTITY (1, 1) NOT NULL,
    [TariffName]  VARCHAR (100) NULL,
    [JurType]     BIT           NULL,
    [ttID]        INT           NULL,
    [DistStart]   INT           NULL,
    [DistEnd]     INT           NULL,
    [withSped]    BIT           NULL,
    [isDel]       BIT           DEFAULT ((0)) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__nlTariff__5B00107BF9BB64C1]
    ON [NearLogistic].[nlTariffs]([nlTariffsID] ASC);

