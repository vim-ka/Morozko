CREATE TABLE [dbo].[SSmain] (
    [ssid]      INT             IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME        NULL,
    [TM]        CHAR (8)        NULL,
    [MarshDay]  DATETIME        NULL,
    [Marsh]     INT             NULL,
    [OP]        INT             NULL,
    [ErrCount]  INT             NULL,
    [ErrQty]    DECIMAL (12, 3) NULL,
    [ErrMoney]  MONEY           NULL,
    [ErrWeight] DECIMAL (10, 3) NULL,
    [Done]      INT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ssid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ошибка в весе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'ErrWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ошибка в ценах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'ErrMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во ошибок по товару', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'ErrQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во ошибок по строчкам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'ErrCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'Marsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSmain', @level2type = N'COLUMN', @level2name = N'MarshDay';

