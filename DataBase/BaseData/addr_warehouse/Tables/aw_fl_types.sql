CREATE TABLE [addr_warehouse].[aw_fl_types] (
    [id]           INT         NOT NULL,
    [fl_type_name] VARCHAR (2) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'типы ярусов', @level0type = N'SCHEMA', @level0name = N'addr_warehouse', @level1type = N'TABLE', @level1name = N'aw_fl_types';

