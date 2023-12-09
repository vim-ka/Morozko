CREATE TABLE [dbo].[VehType] (
    [VehType]     INT             IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (50)    NULL,
    [TypeName]    VARCHAR (20)    NULL,
    [Weight]      DECIMAL (12, 2) CONSTRAINT [DF__VehType__Weight__74EF1735] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Категории транспорта в зависимости от грузоподъемности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehType';

