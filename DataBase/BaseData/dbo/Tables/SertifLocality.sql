CREATE TABLE [dbo].[SertifLocality] (
    [localityID]   INT           IDENTITY (1, 1) NOT NULL,
    [guid]         VARCHAR (255) NULL,
    [uuid]         VARCHAR (255) NULL,
    [name]         VARCHAR (255) NULL,
    [LocView]      VARCHAR (255) NULL,
    [regionCode]   VARCHAR (255) NULL,
    [type]         VARCHAR (255) NULL,
    [countryGuid]  VARCHAR (255) NULL,
    [regionGuid]   VARCHAR (255) NULL,
    [districtGuid] VARCHAR (255) NULL,
    [cityGuid]     VARCHAR (255) NULL,
    [hasStreets]   BIT           NULL,
    [active]       BIT           NULL,
    [last]         BIT           NULL,
    CONSTRAINT [PK_SertifLocality_localityID] PRIMARY KEY CLUSTERED ([localityID] ASC)
);

