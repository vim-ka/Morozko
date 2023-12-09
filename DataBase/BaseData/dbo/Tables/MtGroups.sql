CREATE TABLE [dbo].[MtGroups] (
    [mtg]     INT      IDENTITY (1, 1) NOT NULL,
    [NDBeg]   DATETIME CONSTRAINT [DF__MtGroups__NDBeg__74DA089C] DEFAULT (getdate()) NULL,
    [GroupNo] INT      NULL,
    [Hitag]   INT      NULL,
    UNIQUE NONCLUSTERED ([mtg] ASC)
);

