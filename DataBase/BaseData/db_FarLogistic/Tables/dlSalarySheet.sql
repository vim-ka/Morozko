﻿CREATE TABLE [db_FarLogistic].[dlSalarySheet] (
    [IDSalarySheet] INT      IDENTITY (1, 1) NOT NULL,
    [IDDrv]         INT      NULL,
    [MarshID]       INT      NULL,
    [ChargeType]    INT      NULL,
    [ChargeDate]    DATETIME NULL,
    [ChargeSum]     MONEY    NULL,
    UNIQUE NONCLUSTERED ([IDSalarySheet] ASC)
);


GO
CREATE TRIGGER [db_FarLogistic].[dlSalarySheet_trd] ON [db_FarLogistic].[dlSalarySheet]
WITH EXECUTE AS CALLER
FOR DELETE
AS
insert into db_FarLogistic.dlSalarySheet_log(IDSalarySheet,IDDrv,MarshID,ChargeType,ChargeDate,ChargeSum,LogDate) 
select d.IDSalarySheet,d.IDDrv,d.MarshID,d.ChargeType,d.ChargeDate,ChargeSum,getdate() from deleted d
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма начисления', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'ChargeSum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'ChargeDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование начисления
1 - оклад
2 - премия за пробег', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'ChargeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'маршрут', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'MarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'водитель', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'IDDrv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlSalarySheet', @level2type = N'COLUMN', @level2name = N'IDSalarySheet';

