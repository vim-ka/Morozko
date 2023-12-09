CREATE TABLE [dbo].[KassaLock] (
    [kl]     INT          IDENTITY (1, 1) NOT NULL,
    [dt]     DATETIME     DEFAULT (getdate()) NULL,
    [op]     INT          NULL,
    [p_id]   INT          NULL,
    [comp]   VARCHAR (50) NULL,
    [persid] INT          NULL,
    PRIMARY KEY CLUSTERED ([kl] ASC)
);

