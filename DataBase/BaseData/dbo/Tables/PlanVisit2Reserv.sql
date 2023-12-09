CREATE TABLE [dbo].[PlanVisit2Reserv] (
    [idp]   INT      NOT NULL,
    [pin]   INT      NOT NULL,
    [ag_id] SMALLINT NULL,
    [dn]    TINYINT  NULL,
    [tm]    SMALLINT NULL,
    [dck]   INT      NOT NULL,
    [tip]   TINYINT  CONSTRAINT [DF__PlanVisit2R__tip__3CAD2017] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__PlanVisi__DC501A000AF30760] PRIMARY KEY CLUSTERED ([idp] ASC)
);

