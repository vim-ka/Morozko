CREATE TABLE [dbo].[Contract] (
    [ContID]    INT          IDENTITY (1, 1) NOT NULL,
    [AddDate]   DATETIME     NULL,
    [IO]        INT          NULL,
    [pin]       VARCHAR (30) NULL,
    [out_id]    INT          NULL,
    [CTID]      INT          NULL,
    [TimeType]  INT          NULL,
    [StartDate] DATETIME     NULL,
    [EndDate]   DATETIME     NULL,
    [DepID]     INT          NULL,
    [RespPers]  VARCHAR (50) NULL,
    [Remark]    VARCHAR (50) NULL,
    [ScanDate]  DATETIME     NULL,
    [DelFlag]   INT          NULL,
    PRIMARY KEY CLUSTERED ([ContID] ASC)
);

