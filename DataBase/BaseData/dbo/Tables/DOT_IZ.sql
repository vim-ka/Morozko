CREATE TABLE [dbo].[DOT_IZ] (
    [IZ_ID]  INT             IDENTITY (1, 1) NOT NULL,
    [Act]    TINYINT         CONSTRAINT [DF__DOT_IZ__Act__7E5885DE] DEFAULT ((2)) NULL,
    [Dot]    INT             NULL,
    [ND]     DATETIME        DEFAULT (CONVERT([char](10),getdate(),(104))) NULL,
    [TM]     CHAR (8)        DEFAULT (CONVERT([char](8),getdate(),(108))) NULL,
    [Lotag]  INT             NULL,
    [Cost]   DECIMAL (13, 5) NULL,
    [Price]  DECIMAL (10, 2) NULL,
    [weight] DECIMAL (10, 3) NULL,
    [Qty0]   DECIMAL (10, 3) NULL,
    [Qty1]   DECIMAL (10, 3) NULL,
    PRIMARY KEY CLUSTERED ([IZ_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-переценка 2-испр. 3-возвр.поставщику', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_IZ', @level2type = N'COLUMN', @level2name = N'Act';

