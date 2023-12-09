CREATE TABLE [addr_warehouse].[aw_cells_log] (
    [id]           INT            NULL,
    [skg]          INT            NULL,
    [stl_id]       INT            NULL,
    [cell_fl]      INT            NULL,
    [cell_column]  INT            NULL,
    [cell_vol]     NUMERIC (5, 2) CONSTRAINT [DF__aw_cell__cell_vo__45377920_aw_cells_log] DEFAULT ((0)) NULL,
    [cell_blocked] BIT            CONSTRAINT [DF__aw_cell__cell_bl__444354E7_aw_cells_log] DEFAULT ((0)) NULL,
    [o_type]       VARCHAR (3)    NULL,
    [o_app_name]   VARCHAR (64)   NULL,
    [o_nd]         DATETIME       DEFAULT (getdate()) NULL,
    [o_host]       VARCHAR (64)   DEFAULT (host_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ячейки: stl_id - стеллаж, cell_fl - ярус (A0, A1, ... X), cell_vol - объем, cell_blocked - блокировка ячейки, ', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_cells_log';

