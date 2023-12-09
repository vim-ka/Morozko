CREATE TABLE [dbo].[AddrSpace] (
    [AddrID]    INT        IDENTITY (1, 1) NOT NULL,
    [skg]       INT        NOT NULL,
    [RStorage]  INT        NOT NULL,
    [NLine]     TINYINT    NOT NULL,
    [Level]     TINYINT    NOT NULL,
    [Index]     TINYINT    CONSTRAINT [DF__AddrSpace__Index__650DB527] DEFAULT ((0)) NOT NULL,
    [Depth]     TINYINT    CONSTRAINT [DF__AddrSpace__Depth__68DE460B] DEFAULT ((1)) NOT NULL,
    [Volum]     FLOAT (53) NULL,
    [UsedVol]   FLOAT (53) CONSTRAINT [DF__AddrSpace__UsedV__46FE2F53] DEFAULT ((0)) NULL,
    [ItemCount] SMALLINT   CONSTRAINT [DF__AddrSpace__ItemC__6D23D83B] DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([AddrID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сколько разных товаров в ячейке. Допустимо max 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'ItemCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Использованный объем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'UsedVol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'Volum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина стеллажа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'Depth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для этажей разбитых на несколько полок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'Index';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Этаж A, B, C', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'Level';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ряд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'NLine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стеллаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'RStorage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrSpace', @level2type = N'COLUMN', @level2name = N'skg';

