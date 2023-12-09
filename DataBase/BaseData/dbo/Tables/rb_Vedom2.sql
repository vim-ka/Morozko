CREATE TABLE [dbo].[rb_Vedom2] (
    [rbv2]     INT           IDENTITY (1, 1) NOT NULL,
    [rbv]      INT           NOT NULL,
    [NcodList] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([rbv2] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Связь с главной табл. rb_Vedom', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'rb_Vedom2', @level2type = N'COLUMN', @level2name = N'rbv';

