CREATE TABLE [tax].[user_sets] (
    [usID]     INT IDENTITY (1, 1) NOT NULL,
    [op]       INT NOT NULL,
    [stage_id] INT NOT NULL,
    [isfix]    BIT DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([usID] ASC)
);

