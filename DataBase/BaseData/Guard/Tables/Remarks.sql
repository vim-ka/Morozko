CREATE TABLE [Guard].[Remarks] (
    [rmid]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME     NULL,
    [Razv_ID] INT          NULL,
    [AG_ID]   INT          NULL,
    [Mess]    VARCHAR (80) NULL,
    PRIMARY KEY CLUSTERED ([rmid] ASC)
);

