CREATE TABLE [dbo].[MarshSertif] (
    [Mvk]     INT           IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME      DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]      CHAR (8)      DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Op]      INT           NULL,
    [mhid]    INT           NULL,
    [BrNo]    INT           NULL,
    [Marsh2]  INT           CONSTRAINT [DF__MarshSert__Marsh__644E9B18_copy] DEFAULT ((1)) NULL,
    [isUse]   INT           CONSTRAINT [DF__MarshSert__isUse__32649BCE_copy] DEFAULT ((0)) NOT NULL,
    [VetCost] MONEY         DEFAULT ((0)) NOT NULL,
    [Remark]  VARCHAR (200) NULL,
    UNIQUE NONCLUSTERED ([Mvk] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MarshSertif_uq]
    ON [dbo].[MarshSertif]([mhid] ASC, [BrNo] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshSertif_idx]
    ON [dbo].[MarshSertif]([mhid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - не просмотрена
1 - посетил
2 - не посетил ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSertif', @level2type = N'COLUMN', @level2name = N'isUse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'перед какой точкой заезжать в вет службу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSertif', @level2type = N'COLUMN', @level2name = N'Marsh2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ ветслужбы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSertif', @level2type = N'COLUMN', @level2name = N'BrNo';

