CREATE TABLE [dbo].[SertifPackageLevel] (
    [PackageLevelID] INT           IDENTITY (1, 1) NOT NULL,
    [type]           SMALLINT      NULL,
    [name]           VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifPackageLevel_PackageLevelID_copy] PRIMARY KEY CLUSTERED ([PackageLevelID] ASC)
);

