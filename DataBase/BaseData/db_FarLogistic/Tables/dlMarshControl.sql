CREATE TABLE [db_FarLogistic].[dlMarshControl] (
    [dlMarshID]       INT           NULL,
    [ControlStateID]  INT           NULL,
    [Comment]         VARCHAR (MAX) NULL,
    [ControlDateTime] DATETIME      NULL
);


GO
CREATE TRIGGER [db_FarLogistic].[dlMarshControl_tri] ON [db_FarLogistic].[dlMarshControl]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  update [db_FarLogistic].dlMarshControl set [db_FarLogistic].dlMarshControl.ControlDateTime = getdate()
  from inserted i
  where [db_FarLogistic].dlMarshControl.dlMarshID = i.dlmarshid and
  			[db_FarLogistic].dlMarshControl.NumberStage = i.NumberStage
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата время контроля', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshControl', @level2type = N'COLUMN', @level2name = N'ControlDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshControl', @level2type = N'COLUMN', @level2name = N'Comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор статуса контроля', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshControl', @level2type = N'COLUMN', @level2name = N'ControlStateID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshControl', @level2type = N'COLUMN', @level2name = N'dlMarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица контроля маршрутов', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshControl';

