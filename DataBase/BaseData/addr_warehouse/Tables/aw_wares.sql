CREATE TABLE [addr_warehouse].[aw_wares] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [w_cell]             INT             NULL,
    [w_kol]              INT             DEFAULT ((0)) NULL,
    [w_vol]              NUMERIC (10, 5) DEFAULT ((0)) NULL,
    [w_hitag]            INT             NULL,
    [w_cell_idx]         INT             NULL,
    [w_cell_idx_freevol] NUMERIC (10, 5) NULL,
    CONSTRAINT [aw_wares_fk] FOREIGN KEY ([w_cell]) REFERENCES [addr_warehouse].[aw_cells] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE TRIGGER [addr_warehouse].[aw_wares_trd] ON [addr_warehouse].[aw_wares]
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  insert into aw_wares_Log(id, w_cell, w_tekid, w_kol, o_type, o_app_name)
  select id, w_cell, w_tekid, w_kol, 'INS', APP_NAME() from deleted
END
GO
DISABLE TRIGGER [addr_warehouse].[aw_wares_trd]
    ON [addr_warehouse].[aw_wares];


GO
CREATE TRIGGER [addr_warehouse].[aw_wares_triu] ON [addr_warehouse].[aw_wares]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
BEGIN
  insert into aw_wares_Log(id, w_cell, w_tekid, w_kol, o_type, o_app_name)
  select id, w_cell, w_tekid, w_kol, 'INS', APP_NAME() from inserted
END
GO
DISABLE TRIGGER [addr_warehouse].[aw_wares_triu]
    ON [addr_warehouse].[aw_wares];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'товары, хранящиеся в ячейке', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_wares';

