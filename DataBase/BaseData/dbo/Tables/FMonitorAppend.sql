CREATE TABLE [dbo].[FMonitorAppend] (
    [mdID]     INT           IDENTITY (1, 1) NOT NULL,
    [nd]       DATETIME      NULL,
    [DepID]    INT           NULL,
    [Sv_ID]    INT           NULL,
    [Ag_ID]    INT           NULL,
    [B_ID]     INT           NULL,
    [PicName]  VARCHAR (30)  NULL,
    [PicTrue]  BIT           CONSTRAINT [DF__FMonitorA__PicTr__6E447BAB] DEFAULT ((1)) NULL,
    [PicGrade] SMALLINT      CONSTRAINT [DF__FMonitorA__PicGr__6D505772] DEFAULT ((3)) NULL,
    [remID]    INT           NULL,
    [Note]     VARCHAR (70)  NULL,
    [DateOP]   DATETIME      CONSTRAINT [DF__FMonitorA__DateO__730930C8] DEFAULT ([dbo].[today]()) NULL,
    [OP]       INT           NULL,
    [TimeOP]   VARCHAR (8)   CONSTRAINT [DF__FMonitorA__TimeO__73FD5501] DEFAULT (CONVERT([time],getdate(),(0))) NULL,
    [Comp]     VARCHAR (25)  NULL,
    [DName]    VARCHAR (70)  NULL,
    [SV_Fam]   VARCHAR (100) NULL,
    [AG_Fam]   VARCHAR (100) NULL,
    [B_Fam]    VARCHAR (100) NULL,
    CONSTRAINT [PK__FMonitor__7C74B17272553D1D] PRIMARY KEY CLUSTERED ([mdID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кто внес данные', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата внесения вот этих данных', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'DateOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заметка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'Note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на табл.FMonitorRem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'remID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оценка качества снимка, 1-паршиво, 5-прекрасно', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'PicGrade';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Достоверность,0-левый снимок, 1-правильный', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'PicTrue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания снимка в архиве', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FMonitorAppend', @level2type = N'COLUMN', @level2name = N'nd';

