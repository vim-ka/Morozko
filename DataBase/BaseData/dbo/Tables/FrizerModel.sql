CREATE TABLE [dbo].[FrizerModel] (
    [FMod]      INT             IDENTITY (1, 1) NOT NULL,
    [Model]     VARCHAR (50)    NULL,
    [Volume]    NUMERIC (6, 2)  NULL,
    [Length]    NUMERIC (7, 2)  NULL,
    [High]      NUMERIC (7, 2)  NULL,
    [Depth]     NUMERIC (7, 2)  NULL,
    [High2]     NUMERIC (7, 2)  NULL,
    [Weight]    NUMERIC (10, 2) NULL,
    [Tip]       SMALLINT        CONSTRAINT [DF__FrizerModel__Tip__2E0AC65C] DEFAULT ((0)) NOT NULL,
    [VolumeBox] AS              (((case when [high2]>[high] then [high2] else [high] end*[depth])*[length])/(((100)*(100))*(100))) PERSISTED,
    CONSTRAINT [FrizerModel_fk] FOREIGN KEY ([Tip]) REFERENCES [dbo].[FrizerTip] ([Tip]),
    CONSTRAINT [UQ__FrizerMo__9F1E20796E5DD295] UNIQUE NONCLUSTERED ([FMod] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем занимаемого пространства', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'VolumeBox';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Масса', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'Depth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Высота', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'High';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Длина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'Length';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'Volume';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Модель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerModel', @level2type = N'COLUMN', @level2name = N'Model';

