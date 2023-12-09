CREATE TABLE [dbo].[MobWork] (
    [mwId]     INT             IDENTITY (1, 1) NOT NULL,
    [SaveTime] DATETIME        NULL,
    [FName]    VARCHAR (50)    NULL,
    [FTime]    DATETIME        NULL,
    [MobName]  VARCHAR (10)    NULL,
    [B_ID]     INT             NULL,
    [Nnak]     INT             DEFAULT (0) NULL,
    [Hitag]    INT             NULL,
    [Sklad]    SMALLINT        NULL,
    [Price]    MONEY           DEFAULT (0) NULL,
    [Cost]     MONEY           DEFAULT (0) NULL,
    [Zakaz]    DECIMAL (12, 3) NULL,
    [Saved]    DECIMAL (12, 3) DEFAULT (0) NULL,
    [Remark]   VARCHAR (30)    NULL,
    [CompName] VARCHAR (30)    NULL,
    [Done]     BIT             DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([mwId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [MobWork_idx]
    ON [dbo].[MobWork]([CompName] ASC);

