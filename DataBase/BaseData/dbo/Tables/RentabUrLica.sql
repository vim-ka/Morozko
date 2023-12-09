CREATE TABLE [dbo].[RentabUrLica] (
    [id]    INT           IDENTITY (1, 1) NOT NULL,
    [vname] VARCHAR (255) DEFAULT ('<неизвестно>') NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица для виртуальных групп - юр. лиц для расчета рентабельности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabUrLica';

