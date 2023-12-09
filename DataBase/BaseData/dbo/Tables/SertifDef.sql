CREATE TABLE [dbo].[SertifDef] (
    [SertifDefID]       INT            IDENTITY (1, 1) NOT NULL,
    [guid]              VARCHAR (255)  NULL,
    [uuid]              VARCHAR (255)  NULL,
    [type]              SMALLINT       NULL,
    [name]              VARCHAR (255)  NULL,
    [incorporationForm] VARCHAR (255)  NULL,
    [fullName]          VARCHAR (255)  NULL,
    [fio]               VARCHAR (255)  NULL,
    [passport]          VARCHAR (255)  NULL,
    [inn]               VARCHAR (255)  NULL,
    [kpp]               VARCHAR (255)  NULL,
    [ogrn]              VARCHAR (255)  NULL,
    [juridicalAddress]  VARCHAR (2000) NULL,
    [active]            BIT            NULL,
    [last]              BIT            NULL,
    CONSTRAINT [PK_SertifDef_SertifDefID] PRIMARY KEY CLUSTERED ([SertifDefID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifDef_uuid]
    ON [dbo].[SertifDef]([uuid] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifDef_guid]
    ON [dbo].[SertifDef]([guid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Паспорт (для ИП или физического лица)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'passport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ФИО (для ИП или физического лица)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'fio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полное наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'fullName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организационно-правовая форма', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'incorporationForm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название ХС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип ХС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef', @level2type = N'COLUMN', @level2name = N'type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хозяйствующие субъекты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifDef';

