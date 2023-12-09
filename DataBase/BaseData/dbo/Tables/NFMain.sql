CREATE TABLE [dbo].[NFMain] (
    [id]     INT           IDENTITY (1, 1) NOT NULL,
    [tip]    INT           NULL,
    [nd]     DATETIME      DEFAULT (getdate()) NULL,
    [o_p_id] INT           NULL,
    [p_id]   INT           NULL,
    [trade]  VARCHAR (128) NULL,
    [rs]     INT           NULL,
    CONSTRAINT [NFMain_fk] FOREIGN KEY ([rs]) REFERENCES [dbo].[NFStage] ([id]),
    CONSTRAINT [NFMain_fk2] FOREIGN KEY ([tip]) REFERENCES [dbo].[NFTip] ([id]),
    UNIQUE NONCLUSTERED ([id] ASC)
);

