CREATE TABLE [dbo].[FrizNeedAction] (
    [fnaId]   INT          NULL,
    [fnaName] VARCHAR (20) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'необходимое действие', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizNeedAction';

