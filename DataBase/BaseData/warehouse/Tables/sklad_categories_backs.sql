CREATE TABLE [warehouse].[sklad_categories_backs] (
    [scbid] INT IDENTITY (1, 1) NOT NULL,
    [scid]  INT NOT NULL,
    [btid]  INT NOT NULL,
    [depid] INT DEFAULT ((0)) NOT NULL,
    [sklad] INT DEFAULT ((-1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([scbid] ASC)
);

