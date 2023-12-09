CREATE TABLE [db_FarLogistic].[dlJorneyCargo] (
    [IDReq]        INT           NULL,
    [NumberStage]  INT           NULL,
    [IDNomen]      INT           NULL,
    [NoNomenCargo] VARCHAR (100) NULL,
    [Count]        INT           NULL,
    [CountID]      INT           NULL,
    [Usr]          INT           NULL,
    [NumberPos]    INT           NULL,
    [weight]       INT           NULL,
    [FCount]       INT           NULL,
    [Comment]      VARCHAR (100) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий если недовес', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'Comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактическое количество груза', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'FCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'поле масса по накладным - на будущее при переходе на тарифы, можно будет заполнять при разгрузке', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер позиции', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'NumberPos';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'пользователь', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'Usr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'единица измерения', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'CountID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'Count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'груз не из номенклатуры', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'NoNomenCargo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор номенклатурной единицы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'IDNomen';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер этапа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'NumberStage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор заявки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo', @level2type = N'COLUMN', @level2name = N'IDReq';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица для груза по заявке', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyCargo';

