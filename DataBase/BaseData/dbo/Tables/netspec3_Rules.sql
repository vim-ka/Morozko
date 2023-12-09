CREATE TABLE [dbo].[netspec3_Rules] (
    [ruID] INT          IDENTITY (1, 1) NOT NULL,
    [ND]   DATETIME     DEFAULT ([dbo].[today]()) NULL,
    [Comp] VARCHAR (30) DEFAULT (host_name()) NULL,
    [TM]   VARCHAR (80) DEFAULT ([dbo].[gettime]()) NULL,
    [OP]   INT          NULL,
    PRIMARY KEY CLUSTERED ([ruID] ASC)
);

