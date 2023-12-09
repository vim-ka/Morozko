CREATE TABLE [addr_warehouse].[aw_distr] (
    [id]      INT          IDENTITY (1, 1) NOT NULL,
    [ncom]    INT          NULL,
    [hitag]   INT          NULL,
    [kol]     INT          NULL,
    [sklad]   INT          NULL,
    [cell_id] INT          NULL,
    [txt]     VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

