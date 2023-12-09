CREATE TABLE [dbo].[ShiftP_ID_LOG] (
    [IDS]       VARCHAR (500) NULL,
    [P_ID]      INT           NULL,
    [FIO]       VARCHAR (200) NULL,
    [ShiftDate] DATETIME      DEFAULT (getdate()) NULL,
    [RowID]     INT           IDENTITY (1, 1) NOT NULL,
    UNIQUE NONCLUSTERED ([RowID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код строки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG', @level2type = N'COLUMN', @level2name = N'RowID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG', @level2type = N'COLUMN', @level2name = N'ShiftDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ФИО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG', @level2type = N'COLUMN', @level2name = N'FIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оставшийся', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG', @level2type = N'COLUMN', @level2name = N'P_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коды старые', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG', @level2type = N'COLUMN', @level2name = N'IDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лог процедуры ShiftP_ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShiftP_ID_LOG';

