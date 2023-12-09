CREATE TABLE [db_FarLogistic].[dlPayments] (
    [PaymentID]   INT           IDENTITY (1, 1) NOT NULL,
    [OP]          INT           NULL,
    [PaymentDate] DATETIME      NULL,
    [SumPayment]  MONEY         NULL,
    [CasherID]    INT           NULL,
    [Com]         VARCHAR (200) NULL,
    [WorkID]      INT           NULL,
    [Auto]        BIT           NULL,
    [PaymentType] INT           NULL,
    [IDAccount]   INT           NULL,
    [AdvID]       INT           NULL,
    UNIQUE NONCLUSTERED ([PaymentID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код аванса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'AdvID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код счета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'IDAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип платежа 0 - нал 1 - безнал', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'PaymentType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'флаг авторазноса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'Auto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код работы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'WorkID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'комментарий', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'Com';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код плательщика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'CasherID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма платежа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'SumPayment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата платежа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оператор', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPayments', @level2type = N'COLUMN', @level2name = N'OP';

