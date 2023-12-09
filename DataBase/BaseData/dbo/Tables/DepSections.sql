CREATE TABLE [dbo].[DepSections] (
    [NSec]    INT          IDENTITY (1, 1) NOT NULL,
    [DepID]   INT          NOT NULL,
    [SecName] VARCHAR (70) NULL,
    PRIMARY KEY CLUSTERED ([NSec] ASC)
);

