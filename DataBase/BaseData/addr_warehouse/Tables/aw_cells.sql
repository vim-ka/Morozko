CREATE TABLE [addr_warehouse].[aw_cells] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [skg]            INT             NULL,
    [stl_id]         INT             NULL,
    [cell_fl]        INT             NULL,
    [cell_column]    INT             NULL,
    [cell_vol]       NUMERIC (10, 5) CONSTRAINT [DF__aw_cell__cell_vo__45377920] DEFAULT ((0)) NULL,
    [cell_blocked]   BIT             CONSTRAINT [DF__aw_cell__cell_bl__444354E7] DEFAULT ((0)) NULL,
    [cell_max_wares] INT             CONSTRAINT [DF__aw_cells__cell_m__7F641AB5] DEFAULT ((3)) NULL,
    [cell_free_vol]  AS              ([addr_warehouse].[CalcCellFreeVol]([id])),
    CONSTRAINT [aw_cell_fk] FOREIGN KEY ([cell_fl]) REFERENCES [addr_warehouse].[aw_fl_types] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [aw_cell_fk2] FOREIGN KEY ([stl_id]) REFERENCES [addr_warehouse].[aw_stls] ([id]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [UQ__aw_cell__3213E83EC49159DE] UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE TRIGGER addr_warehouse.aw_cells_trd ON addr_warehouse.aw_cells
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  insert into aw_cells_Log(id, skg, stl_id, cell_fl, cell_column, 
		cell_vol, cell_blocked, o_type, o_app_name)
  select id, skg, stl_id, cell_fl, cell_column, 
		cell_vol, cell_blocked, 'DEL', APP_NAME() from deleted
END
GO
DISABLE TRIGGER [addr_warehouse].[aw_cells_trd]
    ON [addr_warehouse].[aw_cells];


GO
CREATE TRIGGER addr_warehouse.aw_cells_triu ON addr_warehouse.aw_cells
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
BEGIN
  insert into aw_cells_Log(id, skg, stl_id, cell_fl, cell_column, 
		cell_vol, cell_blocked, o_type, o_app_name)
  select id, skg, stl_id, cell_fl, cell_column, 
		cell_vol, cell_blocked, 'INS', APP_NAME() from inserted
END
GO
DISABLE TRIGGER [addr_warehouse].[aw_cells_triu]
    ON [addr_warehouse].[aw_cells];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ячейки: stl_id - стеллаж, cell_fl - ярус (A0, A1, ... X), cell_vol - объем, cell_blocked - блокировка ячейки, ', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_cells';

