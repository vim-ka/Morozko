CREATE TABLE [Guard].[FMonitorPics] (
    [mpID]     INT          IDENTITY (1, 1) NOT NULL,
    [fmID]     INT          NOT NULL,
    [Done]     BIT          DEFAULT ((0)) NULL,
    [Note]     VARCHAR (50) NULL,
    [Grp]      SMALLINT     CONSTRAINT [DF__FMonitorPic__Grp__33CDC153] DEFAULT (NULL) NULL,
    [SaveTmMn] SMALLINT     DEFAULT ([dbo].[fnCurrentMinutes]()) NULL,
    [OldGrp]   SMALLINT     NULL,
    [Md5hash]  VARCHAR (32) NULL,
    PRIMARY KEY CLUSTERED ([mpID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [fmid_idx]
    ON [Guard].[FMonitorPics]([fmID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущее время, выраженное в минутах после полуночи, от 0 до 1439.', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'FMonitorPics', @level2type = N'COLUMN', @level2name = N'SaveTmMn';

