CREATE TABLE [dbo].[SertifCountry] (
    [CountryID]   INT           IDENTITY (1, 1) NOT NULL,
    [guid]        VARCHAR (255) NULL,
    [uuid]        VARCHAR (255) NULL,
    [name]        VARCHAR (255) NULL,
    [fullname]    VARCHAR (255) NULL,
    [englishName] VARCHAR (255) NULL,
    [code]        VARCHAR (2)   NULL,
    [code3]       VARCHAR (3)   NULL,
    [NCnt]        NUMERIC (18)  NULL,
    [active]      BIT           NULL,
    [last]        BIT           NULL,
    CONSTRAINT [PK_SertifCountry_CountryID_copy] PRIMARY KEY CLUSTERED ([CountryID] ASC)
);

