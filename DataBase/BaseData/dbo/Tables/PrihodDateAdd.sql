CREATE TABLE [dbo].[PrihodDateAdd] (
    [PrihodDateAddID]   INT          IDENTITY (1, 1) NOT NULL,
    [PrihodDateAddName] VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([PrihodDateAddID] ASC) WITH (ALLOW_PAGE_LOCKS = OFF, ALLOW_ROW_LOCKS = OFF)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий к сроку хранения номенклатуры(тип)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodDateAdd', @level2type = N'COLUMN', @level2name = N'PrihodDateAddName';

