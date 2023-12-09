CREATE TABLE [dbo].[Dover2PrintLog] (
    [DPLID]      INT          IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME     DEFAULT ([dbo].[today]()) NULL,
    [TM]         VARCHAR (8)  DEFAULT ([dbo].[GetTime]()) NULL,
    [OP]         INT          NULL,
    [datnom]     INT          NOT NULL,
    [Printcount] SMALLINT     DEFAULT ((0)) NULL,
    [CompName]   VARCHAR (30) DEFAULT (host_name()) NULL,
    [dover_type] INT          DEFAULT ((0)) NOT NULL,
    [DovStat]    INT          DEFAULT ((1)) NOT NULL,
    [ScanND]     DATETIME     NULL,
    [NdReturn]   DATETIME     NULL,
    [DCK]        INT          DEFAULT ((0)) NOT NULL,
    [NDUse]      DATETIME     NULL,
    [SumUse]     MONEY        DEFAULT ((0)) NOT NULL,
    [MhID]       INT          DEFAULT ((0)) NOT NULL,
    [drID]       INT          NULL,
    [DovNom]     VARCHAR (16) NULL,
    PRIMARY KEY CLUSTERED ([DPLID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Dover2idx]
    ON [dbo].[Dover2PrintLog]([datnom] ASC);

