CREATE TABLE [dbo].[SSEditLog] (
    [logId]       INT      IDENTITY (1, 1) NOT NULL,
    [ssid]        INT      NULL,
    [Nd]          DATETIME DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [Tm]          CHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Op]          INT      NULL,
    [ErrCount]    INT      NULL,
    [NewErrCount] INT      NULL,
    [ErrQty]      INT      NULL,
    [NewErrQty]   INT      NULL,
    [ErrMoney]    MONEY    NULL,
    [NewErrMoney] MONEY    NULL,
    PRIMARY KEY CLUSTERED ([logId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новоя Ошибка в ценах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'NewErrMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ошибка в ценах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'ErrMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новое кол-во ошибок по товару', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'NewErrQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во ошибок по товару', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'ErrQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новое кол-во ошибочных строк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'NewErrCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во ошибочных строк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'ErrCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSEditLog', @level2type = N'COLUMN', @level2name = N'Op';

