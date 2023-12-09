CREATE TABLE [tax].[payments] (
    [payment_id]       INT      IDENTITY (1, 1) NOT NULL,
    [work_id]          INT      NULL,
    [nd]               DATETIME DEFAULT (CONVERT([varchar],getdate(),(104))) NOT NULL,
    [payment]          MONEY    DEFAULT ((0)) NOT NULL,
    [payment_state_id] INT      DEFAULT ((0)) NOT NULL,
    [op]               INT      NOT NULL,
    [isdel]            BIT      DEFAULT ((0)) NOT NULL,
    [job_id]           INT      DEFAULT ((-1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([payment_id] ASC)
);

