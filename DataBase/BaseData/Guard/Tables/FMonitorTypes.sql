CREATE TABLE [Guard].[FMonitorTypes] (
    [Grp]       SMALLINT      IDENTITY (1, 1) NOT NULL,
    [ShortName] VARCHAR (4)   NULL,
    [pattern]   VARCHAR (12)  NULL,
    [GrpName]   VARCHAR (40)  NULL,
    [DepsList]  VARCHAR (300) NULL,
    [OldGrp]    SMALLINT      NULL,
    PRIMARY KEY CLUSTERED ([Grp] ASC)
);

