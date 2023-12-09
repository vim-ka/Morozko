CREATE TABLE [dbo].[Country] (
    [NCnt]     INT          IDENTITY (1, 1) NOT NULL,
    [CName]    VARCHAR (50) NULL,
    [CyrCode]  VARCHAR (3)  NULL,
    [LatCode2] VARCHAR (2)  NULL,
    [LatCode3] VARCHAR (3)  NULL,
    [NOM]      INT          NULL,
    PRIMARY KEY CLUSTERED ([NCnt] ASC),
    CONSTRAINT [Country_uq] UNIQUE NONCLUSTERED ([LatCode2] ASC),
    CONSTRAINT [Country_uq2] UNIQUE NONCLUSTERED ([LatCode3] ASC),
    CONSTRAINT [Country_uq3] UNIQUE NONCLUSTERED ([CyrCode] ASC)
);

