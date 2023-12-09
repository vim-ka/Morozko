CREATE TABLE [dbo].[FrizerTipDet] (
    [DetTip]     INT          NOT NULL,
    [Tip]        INT          NULL,
    [DetTipName] VARCHAR (40) NULL,
    [mPrice]     MONEY        NULL,
    CONSTRAINT [PK_FRIZERTIPDET] PRIMARY KEY NONCLUSTERED ([DetTip] ASC)
);

