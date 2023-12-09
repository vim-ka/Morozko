CREATE TABLE [Guard].[FMonitorLook] (
    [nd]   DATETIME    DEFAULT ([dbo].[today]()) NULL,
    [tm]   VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [OP]   INT         NULL,
    [MpID] INT         NULL
);


GO
CREATE NONCLUSTERED INDEX [FMonitorLook_Op_MpID_idx]
    ON [Guard].[FMonitorLook]([OP] ASC, [MpID] ASC);

