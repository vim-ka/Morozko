CREATE TABLE [db_FarLogistic].[dlExpence] (
    [rowid]     INT            IDENTITY (1, 1) NOT NULL,
    [Amort]     FLOAT (53)     NULL,
    [Strah]     FLOAT (53)     NULL,
    [Serv]      FLOAT (53)     NULL,
    [Fuel]      FLOAT (53)     NULL,
    [DriverZar] FLOAT (53)     NULL,
    [LogicZar]  FLOAT (53)     NULL,
    [Other]     FLOAT (53)     NULL,
    [Handler]   FLOAT (53)     NULL,
    [IDVehTYpe] INT            NULL,
    [DateStart] DATETIME       NULL,
    [PriceKM]   MONEY          NULL,
    [KMPalCost] MONEY          NULL,
    [MinCost]   MONEY          NULL,
    [DotCost]   MONEY          NULL,
    [MinRaceKM] INT            NULL,
    [percent]   DECIMAL (7, 4) DEFAULT ((100.0)) NOT NULL,
    CONSTRAINT [dlExpence_pk] PRIMARY KEY CLUSTERED ([rowid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Протяженность минимального рейса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'MinRaceKM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость точки сверх 2-х', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'DotCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальный рейс', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'MinCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость 1 км \ паллета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'KMPalCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент дохода владельца', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Handler';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент прочие расходы и налоги', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Other';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на зарплату руководителей, логистов, диспетчеров', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'LogicZar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на зарплату водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'DriverZar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на топливо', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Fuel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на сервис', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Serv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на страховку', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Strah';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент на амортизацию', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlExpence', @level2type = N'COLUMN', @level2name = N'Amort';

