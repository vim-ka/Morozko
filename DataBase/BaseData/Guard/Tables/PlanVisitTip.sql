CREATE TABLE [Guard].[PlanVisitTip] (
    [tip]       INT          IDENTITY (1, 1) NOT NULL,
    [Shortname] VARCHAR (5)  NULL,
    [Fullname]  VARCHAR (40) NULL,
    PRIMARY KEY CLUSTERED ([tip] ASC)
);

