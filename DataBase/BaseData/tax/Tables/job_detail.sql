CREATE TABLE [tax].[job_detail] (
    [job_detail_id] INT           IDENTITY (1, 1) NOT NULL,
    [job_id]        INT           NOT NULL,
    [remark]        VARCHAR (500) NOT NULL,
    [job_type]      INT           NOT NULL,
    [op]            INT           NOT NULL,
    [comp]          VARCHAR (30)  DEFAULT (host_name()) NOT NULL,
    [dt]            DATETIME      DEFAULT (getdate()) NULL,
    [isdel]         BIT           DEFAULT ((0)) NULL,
    [deep]          INT           NOT NULL,
    [debt]          MONEY         NOT NULL,
    [overdue]       MONEY         NOT NULL,
    PRIMARY KEY CLUSTERED ([job_detail_id] ASC)
);

