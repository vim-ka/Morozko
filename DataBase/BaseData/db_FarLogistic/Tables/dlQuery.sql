CREATE TABLE [db_FarLogistic].[dlQuery] (
    [ID]    INT  IDENTITY (72, 1) NOT NULL,
    [query] TEXT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текст запроса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlQuery', @level2type = N'COLUMN', @level2name = N'query';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор запроса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlQuery', @level2type = N'COLUMN', @level2name = N'ID';

