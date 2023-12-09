CREATE TABLE [warehouse].[sklad_ngrp_forBack] (
    [ufbID]    INT IDENTITY (1, 1) NOT NULL,
    [ngrp]     INT DEFAULT ((-1)) NOT NULL,
    [backtype] INT DEFAULT ((-1)) NOT NULL,
    [sklad]    INT DEFAULT ((-1)) NOT NULL,
    [DepID]    INT CONSTRAINT [DF__sklad_ngr__DepID__4D8E5EAD] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ufbID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [sklad_ngrp_forBack_uq]
    ON [warehouse].[sklad_ngrp_forBack]([ngrp] ASC, [backtype] ASC, [sklad] ASC, [DepID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_ngrp_forBack', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_ngrp_forBack', @level2type = N'COLUMN', @level2name = N'sklad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип возврата', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_ngrp_forBack', @level2type = N'COLUMN', @level2name = N'backtype';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код категории', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_ngrp_forBack', @level2type = N'COLUMN', @level2name = N'ngrp';

