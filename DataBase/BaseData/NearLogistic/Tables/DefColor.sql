CREATE TABLE [NearLogistic].[DefColor] (
    [dcID]     INT          IDENTITY (1, 1) NOT NULL,
    [pin]      INT          NOT NULL,
    [color]    VARCHAR (19) DEFAULT ('#009600') NOT NULL,
    [ismaster] BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__DefColor__2075E400BD72F853] PRIMARY KEY CLUSTERED ([dcID] ASC)
);

