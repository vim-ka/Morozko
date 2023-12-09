CREATE TABLE [dbo].[TSDTask] (
    [id]     INT           IDENTITY (1, 1) NOT NULL,
    [tip]    INT           NULL,
    [code]   VARCHAR (60)  NULL,
    [txt]    VARCHAR (255) NULL,
    [stat]   INT           NULL,
    [from_]  VARCHAR (60)  NULL,
    [to_]    VARCHAR (60)  NULL,
    [dt]     DATETIME      NULL,
    [parent] INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip - тип задания
code - код объекта(накладной, товара и т.д.)
txt - описание
stat - статус задания
from - от кого
to - кому
dt - дата время задания
parent - задание-родитель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSDTask';

