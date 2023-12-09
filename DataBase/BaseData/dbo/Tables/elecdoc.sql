CREATE TABLE [dbo].[elecdoc] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [reqnum]      INT           NULL,
    [docext]      VARCHAR (5)   NULL,
    [dochid]      INT           CONSTRAINT [DF__helptempl__dochi__73128712_elecdoc] DEFAULT ((-1)) NULL,
    [docimage]    IMAGE         NULL,
    [docprim]     VARCHAR (200) NULL,
    [docsize]     INT           NULL,
    [doctemppath] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

