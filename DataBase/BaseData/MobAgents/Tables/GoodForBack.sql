CREATE TABLE [MobAgents].[GoodForBack] (
    [id]        INT   NULL,
    [hitag]     INT   NULL,
    [FirmGroup] INT   NULL,
    [Price]     MONEY NULL,
    [Sklad]     INT   NULL,
    [PLID]      INT   NULL,
    [GID]       INT   IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [GoodForBack_pk] PRIMARY KEY CLUSTERED ([GID] ASC),
    CONSTRAINT [GoodForBack_uq] UNIQUE NONCLUSTERED ([FirmGroup] ASC, [hitag] ASC, [PLID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [GoodForBack_idx]
    ON [MobAgents].[GoodForBack]([hitag] ASC);

