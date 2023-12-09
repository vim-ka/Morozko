CREATE TABLE [dbo].[DelivGroups] (
    [DgID]      INT         IDENTITY (1, 1) NOT NULL,
    [DelivGR]   SMALLINT    NULL,
    [Reg_ID]    VARCHAR (3) DEFAULT ('') NULL,
    [DayOfWeek] TINYINT     DEFAULT ((0)) NULL,
    [SkladNo]   SMALLINT    DEFAULT ((0)) NULL,
    [Ngrp]      INT         DEFAULT ((0)) NULL,
    [DepID]     INT         DEFAULT ((0)) NULL,
    [SV_ID]     INT         DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([DgID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DelivGroups__uq]
    ON [dbo].[DelivGroups]([Reg_ID] ASC, [DayOfWeek] ASC, [SkladNo] ASC, [DepID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Супервайзер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'SV_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Товарная группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'Ngrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'SkladNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'День недели', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'DayOfWeek';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Регион доставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'Reg_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Группа доставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DelivGroups', @level2type = N'COLUMN', @level2name = N'DelivGR';

