CREATE TABLE [tax].[job] (
    [job_id]   INT            IDENTITY (1, 1) NOT NULL,
    [pin]      INT            NOT NULL,
    [closed]   BIT            DEFAULT ((0)) NOT NULL,
    [isSingle] BIT            DEFAULT ((0)) NOT NULL,
    [remark]   VARCHAR (3000) DEFAULT ('') NOT NULL,
    [stage_id] INT            DEFAULT ((-1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([job_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'если надо обрабатывать 1 точку сети', @level0type = N'SCHEMA', @level0name = N'tax', @level1type = N'TABLE', @level1name = N'job', @level2type = N'COLUMN', @level2name = N'isSingle';

