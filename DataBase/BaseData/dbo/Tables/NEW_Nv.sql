CREATE TABLE [dbo].[NEW_Nv] (
    [nvId]      INT              IDENTITY (1, 1) NOT NULL,
    [DatNom]    BIGINT           NULL,
    [TekID]     INT              NULL,
    [Hitag]     INT              NULL,
    [Price]     MONEY            NOT NULL,
    [Cost]      MONEY            NOT NULL,
    [Kol]       DECIMAL (10, 3)  DEFAULT ((0)) NOT NULL,
    [Kol_B]     DECIMAL (10, 3)  DEFAULT ((0)) NOT NULL,
    [Sklad]     SMALLINT         NULL,
    [OrigPrice] DECIMAL (10, 2)  NULL,
    [ag_id]     INT              NULL,
    [UnID]      TINYINT          CONSTRAINT [DF__NV__UnID__088FF441_copy] DEFAULT ((0)) NULL,
    [OrigUnid]  TINYINT          DEFAULT ((0)) NULL,
    [K]         DECIMAL (18, 10) DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([nvId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NV_uq]
    ON [dbo].[NEW_Nv]([DatNom] ASC, [TekID] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_tekid_idx]
    ON [dbo].[NEW_Nv]([TekID] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_hitag_idx]
    ON [dbo].[NEW_Nv]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [NV_Datnom_idx]
    ON [dbo].[NEW_Nv]([DatNom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ед.изм. в табл. Units', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Nv', @level2type = N'COLUMN', @level2name = N'UnID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена склада в момент продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Nv', @level2type = N'COLUMN', @level2name = N'OrigPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Nv', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Nv', @level2type = N'COLUMN', @level2name = N'Price';

