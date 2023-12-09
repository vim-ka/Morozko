CREATE TABLE [db_FarLogistic].[dlMarshExpence] (
    [MarshID]    INT   NULL,
    [ExpenceID]  INT   NULL,
    [Cost]       MONEY DEFAULT ((0)) NULL,
    [MarshExpID] INT   IDENTITY (1, 1) NOT NULL,
    [WorkID]     INT   DEFAULT ((0)) NOT NULL,
    CONSTRAINT [dlMarshExpence_pk] PRIMARY KEY CLUSTERED ([MarshExpID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshExpence', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип расхода', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshExpence', @level2type = N'COLUMN', @level2name = N'ExpenceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД Маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshExpence', @level2type = N'COLUMN', @level2name = N'MarshID';

