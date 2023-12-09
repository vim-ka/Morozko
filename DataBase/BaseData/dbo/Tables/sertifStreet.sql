CREATE TABLE [dbo].[sertifStreet] (
    [StreetID]     INT           IDENTITY (1, 1) NOT NULL,
    [guid]         VARCHAR (255) NULL,
    [uuid]         VARCHAR (255) NULL,
    [name]         VARCHAR (255) NULL,
    [StreetView]   VARCHAR (255) NULL,
    [regionCode]   VARCHAR (255) NULL,
    [type]         VARCHAR (255) NULL,
    [localityGuid] VARCHAR (255) NULL,
    [countryGuid]  VARCHAR (255) NULL,
    [active]       BIT           NULL,
    [last]         BIT           NULL,
    CONSTRAINT [PK_sertifStreet_StreetID] PRIMARY KEY CLUSTERED ([StreetID] ASC)
);

