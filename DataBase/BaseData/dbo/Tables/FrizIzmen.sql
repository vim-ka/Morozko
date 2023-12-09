CREATE TABLE [dbo].[FrizIzmen] (
    [FrIzm]  INT         IDENTITY (1, 1) NOT NULL,
    [nd]     DATETIME    DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [tm]     VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Act]    VARCHAR (4) NULL,
    [Op]     INT         NULL,
    [Nom]    INT         NULL,
    [Ncod]   INT         NULL,
    [OperNo] INT         NULL,
    UNIQUE NONCLUSTERED ([FrIzm] ASC)
);

