CREATE TABLE [dbo].[ForGet] (
    [fgid] INT          IDENTITY (1, 1) NOT NULL,
    [ND]   DATETIME     NULL,
    [b_id] INT          NULL,
    [op]   INT          NULL,
    [Pay]  MONEY        NULL,
    [Rem]  VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([fgid] ASC)
);

