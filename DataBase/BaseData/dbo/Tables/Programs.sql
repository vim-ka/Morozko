CREATE TABLE [dbo].[Programs] (
    [Prg]        INT             NULL,
    [PrgName]    VARCHAR (50)    NULL,
    [Descr]      VARCHAR (100)   NULL,
    [ExeName]    VARCHAR (100)   NULL,
    [Source]     VARCHAR (200)   NULL,
    [PrgPicture] VARBINARY (MAX) NULL,
    UNIQUE NONCLUSTERED ([Prg] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название программы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Programs', @level2type = N'COLUMN', @level2name = N'PrgName';

