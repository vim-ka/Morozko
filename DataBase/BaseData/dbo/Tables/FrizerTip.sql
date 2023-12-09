CREATE TABLE [dbo].[FrizerTip] (
    [Tip]     SMALLINT     NOT NULL,
    [tipName] VARCHAR (50) NULL,
    [ord]     INT          DEFAULT ((-1)) NULL,
    CONSTRAINT [FrizerTip_pk] PRIMARY KEY CLUSTERED ([Tip] ASC)
);

