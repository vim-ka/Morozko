CREATE TABLE [dbo].[LaunchCompPrg] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [comp]       VARCHAR (100) NOT NULL,
    [prg]        INT           NOT NULL,
    [isUpd]      BIT           DEFAULT ((1)) NOT NULL,
    [LastUpdate] DATETIME      DEFAULT (getdate()) NOT NULL,
    [ForceUpd]   BIT           DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

