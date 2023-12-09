CREATE TABLE [dbo].[defconremark] (
    [Dck]  INT          NOT NULL,
    [Mess] VARCHAR (50) NULL,
    [ND]   DATETIME     DEFAULT ([dbo].[today]()) NULL,
    [tm]   VARCHAR (8)  DEFAULT ([dbo].[time]()) NULL,
    [OP]   INT          NULL,
    PRIMARY KEY CLUSTERED ([Dck] ASC)
);

