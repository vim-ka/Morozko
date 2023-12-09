CREATE TABLE [dbo].[MarshType] (
    [typeID] INT          IDENTITY (1, 1) NOT NULL,
    [mtName] VARCHAR (25) NULL,
    [Dist]   FLOAT (53)   NULL,
    PRIMARY KEY CLUSTERED ([typeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'километраж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshType', @level2type = N'COLUMN', @level2name = N'Dist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshType', @level2type = N'COLUMN', @level2name = N'mtName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshType', @level2type = N'COLUMN', @level2name = N'typeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица привязки маршрутов в соответствии с киллометражом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshType';

