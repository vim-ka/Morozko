CREATE TABLE [db_FarLogistic].[dlJorneyFiles] (
    [IDReq]    INT             NULL,
    [NumbFile] INT             NULL,
    [FileBody] VARBINARY (MAX) NULL,
    [FileExt]  VARCHAR (5)     NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расширение файла', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyFiles', @level2type = N'COLUMN', @level2name = N'FileExt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тело файла', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyFiles', @level2type = N'COLUMN', @level2name = N'FileBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер файла', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyFiles', @level2type = N'COLUMN', @level2name = N'NumbFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор заявки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyFiles', @level2type = N'COLUMN', @level2name = N'IDReq';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица для хранения прикрепленных файлов', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyFiles';

