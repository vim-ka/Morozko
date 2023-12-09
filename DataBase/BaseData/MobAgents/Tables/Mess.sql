CREATE TABLE [MobAgents].[Mess] (
    [MessID]   INT           IDENTITY (1, 1) NOT NULL,
    [ag_id]    INT           NULL,
    [pin]      INT           NULL,
    [dck]      INT           NULL,
    [ND]       DATETIME      DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [tm]       CHAR (8)      DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Remark]   VARCHAR (100) NULL,
    [MessType] INT           NULL,
    [data0]    INT           NULL,
    UNIQUE NONCLUSTERED ([MessID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Mess_idx5]
    ON [MobAgents].[Mess]([dck] ASC);


GO
CREATE NONCLUSTERED INDEX [Mess_idx4]
    ON [MobAgents].[Mess]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [Mess_idx2]
    ON [MobAgents].[Mess]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Mess_idx]
    ON [MobAgents].[Mess]([ND] ASC);

