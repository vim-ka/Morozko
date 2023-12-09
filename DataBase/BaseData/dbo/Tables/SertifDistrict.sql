CREATE TABLE [dbo].[SertifDistrict] (
    [DistrictID]  INT           IDENTITY (1, 1) NOT NULL,
    [guid]        VARCHAR (255) NULL,
    [uuid]        VARCHAR (255) NULL,
    [name]        VARCHAR (255) NULL,
    [DisView]     VARCHAR (255) NULL,
    [regionCode]  VARCHAR (255) NULL,
    [type]        VARCHAR (255) NULL,
    [countryGuid] VARCHAR (255) NULL,
    [regionGuid]  VARCHAR (255) NULL,
    [hasStreets]  BIT           NULL,
    [active]      BIT           NULL,
    [last]        BIT           NULL,
    CONSTRAINT [PK_SertifDistrict_DistrictID] PRIMARY KEY CLUSTERED ([DistrictID] ASC)
);

