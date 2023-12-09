CREATE TABLE [dbo].[DistKmPay] (
    [kp]      INT        IDENTITY (1, 1) NOT NULL,
    [Weight]  FLOAT (53) DEFAULT ((0)) NOT NULL,
    [DistPay] MONEY      CONSTRAINT [DF__DistKmPay__DistP__542D41E8] DEFAULT ((0)) NOT NULL,
    [typeID]  INT        NULL,
    PRIMARY KEY CLUSTERED ([kp] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип маршрута из таблицы MarshType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DistKmPay', @level2type = N'COLUMN', @level2name = N'typeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'плата за 1 км', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DistKmPay', @level2type = N'COLUMN', @level2name = N'DistPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тоннаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DistKmPay', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Справочник цен по маршруту (плата за 1 км), в соответствии с тоннажом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DistKmPay';

