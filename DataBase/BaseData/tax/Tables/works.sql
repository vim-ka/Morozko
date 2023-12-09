CREATE TABLE [tax].[works] (
    [work_id]     INT           IDENTITY (1, 1) NOT NULL,
    [dck]         INT           NOT NULL,
    [stage_id]    INT           DEFAULT ((-1)) NOT NULL,
    [remark]      VARCHAR (500) DEFAULT ('') NOT NULL,
    [work_closed] BIT           DEFAULT ((0)) NOT NULL,
    [dt_start]    VARCHAR (10)  CONSTRAINT [DF__works__dt_start__10062D80] DEFAULT (CONVERT([varchar],getdate(),(104))) NOT NULL,
    [dt_end]      VARCHAR (10)  NULL,
    [op]          INT           NOT NULL,
    [op_fio]      VARCHAR (200) NOT NULL,
    [op_end]      INT           NULL,
    [op_end_fio]  VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([work_id] ASC)
);

