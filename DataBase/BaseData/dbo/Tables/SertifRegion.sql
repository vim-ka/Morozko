CREATE TABLE [dbo].[SertifRegion] (
    [RegionID]    INT           IDENTITY (1, 1) NOT NULL,
    [guid]        VARCHAR (255) NULL,
    [uuid]        VARCHAR (255) NULL,
    [name]        VARCHAR (255) NULL,
    [englishName] VARCHAR (255) NULL,
    [RegView]     VARCHAR (255) NULL,
    [regionCode]  VARCHAR (255) NULL,
    [type]        VARCHAR (255) NULL,
    [countryGuid] VARCHAR (255) NULL,
    [hasStreets]  BIT           NULL,
    [active]      BIT           NULL,
    [last]        BIT           NULL,
    CONSTRAINT [PK_SertifRegion_RegionID] PRIMARY KEY CLUSTERED ([RegionID] ASC)
);

