CREATE TABLE [dbo].[DefRemark] (
    [pin]           INT             NOT NULL,
    [IncomePlan]    DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Mess]          VARCHAR (50)    NULL,
    [ND]            DATETIME        DEFAULT ([dbo].[today]()) NULL,
    [tm]            VARCHAR (8)     DEFAULT ([dbo].[time]()) NULL,
    [OP]            INT             NULL,
    [BuhRemark]     VARCHAR (20)    NULL,
    [BuhRemarkDate] DATETIME        DEFAULT ([dbo].[today]()) NULL,
    PRIMARY KEY CLUSTERED ([pin] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Время', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Дата заведения или коррекции записи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Условие оплаты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'Mess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'План сбора просрочки, р.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'IncomePlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Мастер сети или одиночный покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefRemark', @level2type = N'COLUMN', @level2name = N'pin';

