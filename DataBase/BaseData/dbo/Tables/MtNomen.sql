CREATE TABLE [dbo].[MtNomen] (
    [Lotag]     INT           IDENTITY (1, 1) NOT NULL,
    [Nname]     VARCHAR (100) NULL,
    [NetShop]   TINYINT       DEFAULT (1) NULL,
    [SelfHitag] VARCHAR (15)  NULL,
    PRIMARY KEY CLUSTERED ([Lotag] ASC)
);

