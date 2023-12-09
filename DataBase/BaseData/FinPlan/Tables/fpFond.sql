CREATE TABLE [FinPlan].[fpFond] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [depid]     INT           NULL,
    [dname]     VARCHAR (128) NULL,
    [dep_chief] INT           NULL,
    [closed]    BIT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

