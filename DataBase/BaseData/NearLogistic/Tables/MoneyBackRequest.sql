CREATE TABLE [NearLogistic].[MoneyBackRequest] (
    [mbrID]  INT           IDENTITY (1, 1) NOT NULL,
    [nd]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [comp]   VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [mhid]   INT           DEFAULT ((0)) NOT NULL,
    [dck]    INT           NOT NULL,
    [pin]    INT           NOT NULL,
    [ag_id]  INT           NOT NULL,
    [our_id] INT           NOT NULL,
    [sumPay] MONEY         NOT NULL,
    [remark] VARCHAR (500) NULL,
    [done]   BIT           DEFAULT (CONVERT([bit],(0),(0))) NOT NULL,
    CONSTRAINT [MoneyBackRequest_pk] PRIMARY KEY CLUSTERED ([mbrID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_MoneyBackRequest3]
    ON [NearLogistic].[MoneyBackRequest]([mhid] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MoneyBackRequest2]
    ON [NearLogistic].[MoneyBackRequest]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MoneyBackRequest1]
    ON [NearLogistic].[MoneyBackRequest]([nd] ASC);

