CREATE TABLE [dbo].[NcLock] (
    [StartTime]  DATETIME     DEFAULT (getdate()) NULL,
    [HostName]   VARCHAR (30) NULL,
    [Datnom]     BIGINT       NULL,
    [LastUpdate] DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [NcLock_idx]
    ON [dbo].[NcLock]([HostName] ASC);


GO
CREATE NONCLUSTERED INDEX [NcLock_idx2]
    ON [dbo].[NcLock]([Datnom] ASC);

