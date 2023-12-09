CREATE TABLE [dbo].[Tags] (
    [TagID]      INT           IDENTITY (1, 1) NOT NULL,
    [TagName]    VARCHAR (50)  NULL,
    [TagType]    VARCHAR (MAX) CONSTRAINT [DF__Tag__atrType__151B244E] DEFAULT ('#str') NULL,
    [TagActions] VARCHAR (30)  CONSTRAINT [DF__Tag__atrActions__160F4887] DEFAULT ('#=') NOT NULL,
    [TagIsDel]   BIT           CONSTRAINT [DF__Tag__atrIsDel__17036CC0] DEFAULT ((0)) NOT NULL,
    [TagParent]  INT           CONSTRAINT [DF__Tags__TagParent__2E34E38E] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([TagID] ASC)
);

