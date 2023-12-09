CREATE TABLE [dbo].[SMoveSk] (
    [moveId]  INT      IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME CONSTRAINT [DF__SMoveSk__ND__595C0B59] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]      CHAR (8) CONSTRAINT [DF__SMoveSk__TM__5A502F92] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Nomer]   INT      NULL,
    [IzmND]   DATETIME NULL,
    [OpSk]    INT      NULL,
    [OpNewSk] INT      NULL,
    [Done]    TINYINT  CONSTRAINT [DF__SMoveSk__Done__5867E720] DEFAULT ((0)) NULL,
    CONSTRAINT [SMoveSk_pk] PRIMARY KEY CLUSTERED ([moveId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'состояние перемещения 
(0-не набирался
 1-набран и перемещается
 2-пришел на перемещаемый склад)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk', @level2type = N'COLUMN', @level2name = N'Done';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ оперетора принявшего товар', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk', @level2type = N'COLUMN', @level2name = N'OpNewSk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ оператора, набиравшего товар', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk', @level2type = N'COLUMN', @level2name = N'OpSk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата перемещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk', @level2type = N'COLUMN', @level2name = N'IzmND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ перемещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk', @level2type = N'COLUMN', @level2name = N'Nomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица перемешений товара по складам (сканирование)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSk';

