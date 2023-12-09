CREATE TABLE [tax].[work_det] (
    [work_det_id]  INT            IDENTITY (1, 1) NOT NULL,
    [work_id]      INT            NOT NULL,
    [dt]           VARCHAR (10)   CONSTRAINT [DF__work_det__dt__0A4D542A] DEFAULT (CONVERT([varchar],getdate(),(104))) NOT NULL,
    [tm]           VARCHAR (10)   CONSTRAINT [DF__work_det__tm__0B417863] DEFAULT (CONVERT([varchar],getdate(),(108))) NOT NULL,
    [remark]       VARCHAR (2000) DEFAULT ('') NOT NULL,
    [op]           INT            NOT NULL,
    [isdel]        BIT            DEFAULT ((0)) NOT NULL,
    [work_type_id] INT            DEFAULT ((-1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([work_det_id] ASC)
);

