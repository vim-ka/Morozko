CREATE TABLE [dbo].[DOT_SK] (
    [Lotag]     INT             IDENTITY (1, 1) NOT NULL,
    [Dot]       INT             NULL,
    [Tekid]     INT             NOT NULL,
    [Startid]   INT             NULL,
    [Ncom]      INT             NULL,
    [Ncod]      INT             NULL,
    [Hitag]     INT             NULL,
    [Start]     DECIMAL (10, 3) NULL,
    [StartThis] DECIMAL (10, 3) NULL,
    [Sell]      DECIMAL (10, 3) CONSTRAINT [DF__DOT_SK__Sell__5EDFDA85] DEFAULT ((0)) NULL,
    [Remov]     DECIMAL (10, 3) CONSTRAINT [DF__DOT_SK__Remov__5FD3FEBE] DEFAULT ((0)) NULL,
    [Isprav]    DECIMAL (10, 3) CONSTRAINT [DF__DOT_SK__Isprav__60C822F7] DEFAULT ((0)) NULL,
    [Cost]      DECIMAL (13, 5) NULL,
    [Price]     DECIMAL (10, 2) NULL,
    [Weight]    DECIMAL (10, 3) NULL,
    [MinP]      INT             DEFAULT ((1)) NULL,
    [Mpu]       INT             DEFAULT ((1)) NULL,
    CONSTRAINT [DOT_SK_pk] PRIMARY KEY CLUSTERED ([Lotag] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во мин.парт.в упаковке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Mpu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Миним.партия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'MinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вес единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сейчас StartThis=Start', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'StartThis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поставлено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Start';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'зарезервировано', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Местный № поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Ncom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'зарезервировано', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Startid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Из основной БД', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Tekid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Розн.точка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Dot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Местный уник.ид', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOT_SK', @level2type = N'COLUMN', @level2name = N'Lotag';

