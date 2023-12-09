CREATE TABLE [db_FarLogistic].[dlEmpowermentAct] (
    [ActID]   INT          IDENTITY (1, 1) NOT NULL,
    [ActName] VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([ActID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowermentAct', @level2type = N'COLUMN', @level2name = N'ActName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор действия', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlEmpowermentAct', @level2type = N'COLUMN', @level2name = N'ActID';

