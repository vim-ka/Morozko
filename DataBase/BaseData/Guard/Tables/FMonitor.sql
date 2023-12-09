CREATE TABLE [Guard].[FMonitor] (
    [fmID]      INT           IDENTITY (1, 1) NOT NULL,
    [taskKey]   VARCHAR (20)  NULL,
    [ND]        DATETIME      NULL,
    [ag_id]     INT           NULL,
    [DCK]       INT           NULL,
    [taskname]  VARCHAR (80)  NULL,
    [Done]      BIT           DEFAULT ((0)) NULL,
    [Remark]    VARCHAR (250) NULL,
    [Report]    VARCHAR (200) NULL,
    [SaveDay]   DATETIME      DEFAULT ([dbo].[today]()) NULL,
    [OrigGrp]   SMALLINT      CONSTRAINT [DF__FMonitor__OrigGr__32D99D1A] DEFAULT (NULL) NULL,
    [B_id]      INT           NULL,
    [DepID]     SMALLINT      NULL,
    [Chan]      BIT           DEFAULT ((0)) NULL,
    [OldGrp]    SMALLINT      NULL,
    [Processed] BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([fmID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FMonitor_dck_idx]
    ON [Guard].[FMonitor]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [FMonitor_agid_idx]
    ON [Guard].[FMonitor]([ag_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата записи', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'FMonitor', @level2type = N'COLUMN', @level2name = N'SaveDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сброса задания', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'FMonitor', @level2type = N'COLUMN', @level2name = N'ND';

