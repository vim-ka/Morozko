CREATE TABLE [warehouse].[sklad_category_contains] (
    [sccid] INT IDENTITY (1, 1) NOT NULL,
    [scid]  INT NOT NULL,
    [sklad] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([sccid] ASC)
);

