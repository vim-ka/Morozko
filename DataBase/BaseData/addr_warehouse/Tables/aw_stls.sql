CREATE TABLE [addr_warehouse].[aw_stls] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [skg]             INT            NULL,
    [stl_num]         INT            NULL,
    [stl_tip]         BIT            NULL,
    [stl_columncount] INT            DEFAULT ((10)) NULL,
    [stl_flcount]     INT            DEFAULT ((5)) NULL,
    [stl_depth]       INT            CONSTRAINT [DF__aw_stls__stl_dep__3BCE0A77] DEFAULT ((1)) NULL,
    [stl_stdvol]      NUMERIC (5, 2) DEFAULT ((1.8)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'стеллаж: stl_sk - склад, stl_num - номер, stl_tip - тип (1 - постоянный, 0 - временный)', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_stls';

