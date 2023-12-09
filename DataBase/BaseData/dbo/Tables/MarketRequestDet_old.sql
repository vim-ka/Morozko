CREATE TABLE [dbo].[MarketRequestDet_old] (
    [id]            INT             IDENTITY (1, 1) NOT NULL,
    [mrid]          INT             NULL,
    [otv]           INT             DEFAULT ((-1)) NULL,
    [depid_value]   BIGINT          CONSTRAINT [DF__MarketReq__depid__0D28F57E] DEFAULT ((-1)) NULL,
    [actn_tip]      INT             DEFAULT ((0)) NULL,
    [actn_obj]      SMALLINT        CONSTRAINT [DF__MarketReq__actn___0F113DF0] DEFAULT ((0)) NULL,
    [dtfrom]        DATETIME        NULL,
    [dtto]          DATETIME        NULL,
    [actn_meh]      VARCHAR (1024)  NULL,
    [agplussum]     NUMERIC (12, 2) DEFAULT ((0.0)) NULL,
    [actn_tip_code] INT             NULL,
    [actn_tgt]      VARCHAR (1024)  NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'значение=value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestDet_old', @level2type = N'COLUMN', @level2name = N'depid_value';

