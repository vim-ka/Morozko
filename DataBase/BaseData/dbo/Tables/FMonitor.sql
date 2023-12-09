CREATE TABLE [dbo].[FMonitor] (
    [fmID]     INT           IDENTITY (1, 1) NOT NULL,
    [taskKey]  VARCHAR (20)  NULL,
    [ND]       DATETIME      NULL,
    [ag_id]    INT           NULL,
    [DCK]      INT           NULL,
    [taskname] VARCHAR (80)  NULL,
    [Done]     BIT           CONSTRAINT [DF__FMonitor__Done__43F93C24] DEFAULT ((0)) NULL,
    [Remark]   VARCHAR (200) NULL,
    [Report]   VARCHAR (200) NULL,
    [SaveDay]  DATETIME      CONSTRAINT [DF__FMonitor__SaveDa__4D82A65E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__FMonitor__347091998BA70934] PRIMARY KEY CLUSTERED ([fmID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата записи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitor', @level2type = N'COLUMN', @level2name = N'SaveDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сброса задания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitor', @level2type = N'COLUMN', @level2name = N'ND';

