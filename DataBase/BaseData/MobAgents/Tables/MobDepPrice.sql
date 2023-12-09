CREATE TABLE [MobAgents].[MobDepPrice] (
    [mdp]   INT   IDENTITY (1, 1) NOT NULL,
    [DepID] INT   NULL,
    [ag_id] INT   NULL,
    [pin]   INT   NULL,
    [dck]   INT   NULL,
    [hitag] INT   NULL,
    [Price] MONEY NULL,
    UNIQUE NONCLUSTERED ([mdp] ASC)
);

