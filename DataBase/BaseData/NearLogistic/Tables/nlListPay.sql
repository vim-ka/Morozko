CREATE TABLE [NearLogistic].[nlListPay] (
    [LPID]               INT          IDENTITY (1, 1) NOT NULL,
    [ND]                 DATETIME     DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [Tm]                 VARCHAR (8)  DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [act]                CHAR (3)     NULL,
    [ListNo]             INT          NOT NULL,
    [Op]                 INT          NULL,
    [Remark]             VARCHAR (60) NULL,
    [StartND]            DATETIME     NULL,
    [EndND]              DATETIME     NULL,
    [ttID]               INT          NULL,
    [AdditionalHeaderID] INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [nlListPay_pk] PRIMARY KEY CLUSTERED ([LPID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [nlListPay_uq]
    ON [NearLogistic].[nlListPay]([ListNo] ASC);

