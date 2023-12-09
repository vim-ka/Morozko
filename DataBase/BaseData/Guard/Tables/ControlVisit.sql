CREATE TABLE [Guard].[ControlVisit] (
    [ag_id] INT      NULL,
    [pin]   INT      NULL,
    [tm]    SMALLINT NULL,
    [Done]  BIT      DEFAULT ((0)) NOT NULL
);

