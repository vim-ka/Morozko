CREATE TABLE [NearLogistic].[nlTariffsDet] (
    [nlTariffsDetID]   INT IDENTITY (1, 1) NOT NULL,
    [nlTariffsID]      INT NULL,
    [nlTariffParamsID] INT NULL,
    [nlVehCapacityID]  INT NULL,
    [isDel]            BIT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [UQ__nlTariff__A81FBC12139578BE_copy] UNIQUE NONCLUSTERED ([nlTariffsDetID] ASC)
);

