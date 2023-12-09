CREATE TABLE [addr_warehouse].[aw_wares_log] (
    [id]         INT          NULL,
    [w_cell]     INT          NULL,
    [w_tekid]    INT          NULL,
    [w_kol]      INT          NULL,
    [o_type]     VARCHAR (3)  NULL,
    [o_app_name] VARCHAR (64) NULL,
    [o_nd]       DATETIME     DEFAULT (getdate()) NULL,
    [o_host]     VARCHAR (64) DEFAULT (host_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'товары, хранящиеся в ячейке', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_wares_log';

