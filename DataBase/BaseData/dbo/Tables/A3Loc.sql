CREATE TABLE [dbo].[A3Loc] (
    [NRec]    INT        IDENTITY (1, 1) NOT NULL,
    [TdviID]  INT        DEFAULT ((0)) NULL,
    [A3id0]   INT        DEFAULT ((0)) NULL,
    [Qty]     INT        NULL,
    [UsedVol] FLOAT (53) DEFAULT ((0)) NULL,
    [AddrID]  INT        NULL,
    PRIMARY KEY CLUSTERED ([NRec] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на табл.AddrSpace', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3Loc', @level2type = N'COLUMN', @level2name = N'AddrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем куб.м.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3Loc', @level2type = N'COLUMN', @level2name = N'UsedVol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3Loc', @level2type = N'COLUMN', @level2name = N'Qty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на a3reqdet.a3id0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3Loc', @level2type = N'COLUMN', @level2name = N'A3id0';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на TDVI.ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'A3Loc', @level2type = N'COLUMN', @level2name = N'TdviID';

