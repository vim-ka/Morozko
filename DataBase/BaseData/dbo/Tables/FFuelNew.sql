CREATE TABLE [dbo].[FFuelNew] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [cardnum]     VARCHAR (30)    NULL,
    [nd]          DATETIME        NULL,
    [fueltipname] VARCHAR (60)    NULL,
    [fueltip]     INT             NULL,
    [vol]         NUMERIC (10, 2) NULL,
    [price]       NUMERIC (10, 2) NULL,
    [summa]       NUMERIC (10, 2) NULL,
    [address]     VARCHAR (1000)  NULL,
    [emitent]     INT             NULL,
    [p_id]        INT             NULL,
    [locked]      BIT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx6]
    ON [dbo].[FFuelNew]([price] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx5]
    ON [dbo].[FFuelNew]([vol] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx4]
    ON [dbo].[FFuelNew]([emitent] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx3]
    ON [dbo].[FFuelNew]([cardnum] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx2]
    ON [dbo].[FFuelNew]([fueltip] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx]
    ON [dbo].[FFuelNew]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuelNew_idx_nd]
    ON [dbo].[FFuelNew]([nd] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код компании-эмитента пластиковых карт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FFuelNew', @level2type = N'COLUMN', @level2name = N'emitent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип топлива из нашего справочника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FFuelNew', @level2type = N'COLUMN', @level2name = N'fueltip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'название типа топлива у эмитента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FFuelNew', @level2type = N'COLUMN', @level2name = N'fueltipname';

