CREATE TABLE [dbo].[Incom] (
    [iid]       INT          IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME     NULL,
    [ncod]      INT          NULL,
    [Weight]    SMALLINT     NULL,
    [ProjTime]  CHAR (8)     NULL,
    [FactTime]  CHAR (8)     NULL,
    [CalcTime]  CHAR (8)     NULL,
    [OutStart]  CHAR (8)     NULL,
    [OutFinish] CHAR (8)     NULL,
    [Reason]    VARCHAR (40) NULL,
    [lgs]       INT          DEFAULT (0) NULL,
    [Master]    VARCHAR (30) NULL,
    PRIMARY KEY CLUSTERED ([iid] ASC)
);

