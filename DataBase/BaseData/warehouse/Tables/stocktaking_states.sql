CREATE TABLE [warehouse].[stocktaking_states] (
    [sstID]      INT          IDENTITY (1, 1) NOT NULL,
    [state_name] VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([sstID] ASC)
);

