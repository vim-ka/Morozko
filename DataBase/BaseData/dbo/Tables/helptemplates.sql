CREATE TABLE [dbo].[helptemplates] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [docext]      VARCHAR (5)   NULL,
    [dochid]      INT           DEFAULT ((-1)) NULL,
    [docimage]    IMAGE         NULL,
    [docprim]     VARCHAR (200) NULL,
    [docsize]     INT           NULL,
    [doctemppath] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

