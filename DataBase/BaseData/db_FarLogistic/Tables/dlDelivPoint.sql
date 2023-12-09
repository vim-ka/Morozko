CREATE TABLE [db_FarLogistic].[dlDelivPoint] (
    [dlDelivPointID] INT           IDENTITY (151, 1) NOT NULL,
    [PointName]      VARCHAR (150) NULL,
    [City]           VARCHAR (70)  NULL,
    [Street]         VARCHAR (50)  NULL,
    [House]          VARCHAR (15)  NULL,
    [posx]           FLOAT (53)    NULL,
    [posy]           FLOAT (53)    NULL,
    [Contact]        VARCHAR (50)  NULL,
    [Phone]          VARCHAR (150) NULL,
    [WorkTime]       VARCHAR (40)  NULL,
    [IDReqGroup]     INT           NULL,
    [PointAlies]     VARCHAR (50)  NULL,
    [isDel]          BIT           DEFAULT ((0)) NULL,
    [WorkDays]       INT           NULL,
    [StartWork]      TIME (7)      NULL,
    [EndWork]        TIME (7)      NULL,
    [HoursToLoad]    INT           NULL,
    [HoursToUnLoad]  INT           NULL,
    [Sklad]          VARCHAR (500) NULL,
    [Vet]            VARCHAR (500) NULL,
    [fmtAddress]     VARCHAR (500) DEFAULT ('') NULL,
    PRIMARY KEY CLUSTERED ([dlDelivPointID] ASC),
    UNIQUE NONCLUSTERED ([dlDelivPointID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'форматированный адрес', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'fmtAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время на разгрузку', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'HoursToUnLoad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время на загрузку', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'HoursToLoad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'конец рабочего дня', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'EndWork';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'начало рабочего дня', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'StartWork';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'рабочие дни в формате степеней двойки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'WorkDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Псевдоним', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'PointAlies';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор группы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'IDReqGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время работы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'WorkTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Контактное лицо', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'Contact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Строение', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'House';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Улица', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'Street';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Населенный пункт', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'City';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Точка доставки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDelivPoint', @level2type = N'COLUMN', @level2name = N'PointName';

