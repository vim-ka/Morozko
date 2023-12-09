CREATE TABLE [dbo].[Vehicle] (
    [v_id]            INT              IDENTITY (0, 1) NOT NULL,
    [Model]           VARCHAR (80)     DEFAULT ('') NULL,
    [RegNom]          VARCHAR (20)     DEFAULT ('') NULL,
    [MaxWeight]       INT              DEFAULT ((0)) NULL,
    [CruiseSpeed]     INT              DEFAULT ((0)) NULL,
    [FuelSpend]       FLOAT (53)       DEFAULT ((0)) NULL,
    [Owner]           VARCHAR (40)     DEFAULT ('') NULL,
    [FuelCard]        VARCHAR (12)     DEFAULT ('') NULL,
    [DriverDoc]       VARCHAR (12)     DEFAULT ('') NULL,
    [Self]            TINYINT          DEFAULT (0) NULL,
    [RegTsSer]        VARCHAR (10)     DEFAULT ('') NULL,
    [RegTsNom]        VARCHAR (10)     DEFAULT ('') NULL,
    [tariff1km]       MONEY            CONSTRAINT [DF__Vehicle__tariff1__13BDB718] DEFAULT ((0)) NULL,
    [Reg_ID]          VARCHAR (3)      DEFAULT ('') NULL,
    [VTip]            INT              DEFAULT ((0)) NULL,
    [DepID]           INT              DEFAULT ((0)) NULL,
    [Trailer]         BIT              DEFAULT ((0)) NULL,
    [Volum]           NUMERIC (15, 10) DEFAULT ((0)) NULL,
    [LimitWeight]     INT              DEFAULT ((0)) NULL,
    [CanTrFlg]        BIT              DEFAULT ((0)) NULL,
    [CrId]            INT              DEFAULT ((0)) NOT NULL,
    [Closed]          BIT              DEFAULT ((0)) NULL,
    [VehType]         INT              DEFAULT ((0)) NULL,
    [nlVehCapacityID] INT              DEFAULT ((1)) NULL,
    [Expense]         MONEY            DEFAULT ((0)) NOT NULL,
    [ftID]            INT              DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([v_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Постоянные расходы по машине', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Expense';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Категория из nlVehCapacity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'nlVehCapacityID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'категория транспорта из VehType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'VehType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'неактивная машина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код грузоперевозчика из таблицы Carriers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'CrId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Можно ли к машине прикрепить прицеп', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'CanTrFlg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предельная грузоподъемность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'LimitWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем в м куб.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Volum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прицеп', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Trailer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип машины', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'VTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код региона по которому работает машина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Reg_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тариф за 1 км', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'tariff1km';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Техпаспорт - номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'RegTsNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Техпаспорт - номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'RegTsSer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Владелец является водителем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Self';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Водительское удостоверение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'DriverDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Топливная карта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'FuelCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Владелец', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Owner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расход горючего', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'FuelSpend';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Крейсерская скорость', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'CruiseSpeed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Грузоподъемность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'MaxWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Гос. номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'RegNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Модель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'Model';

