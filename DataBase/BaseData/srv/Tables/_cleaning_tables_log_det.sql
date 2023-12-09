CREATE TABLE [srv].[_cleaning_tables_log_det] (
    [ctldID]            INT            IDENTITY (1, 1) NOT NULL,
    [ctlID]             INT            NOT NULL,
    [table_name]        NVARCHAR (50)  NULL,
    [inc_field]         NVARCHAR (50)  NULL,
    [filter_field]      NVARCHAR (50)  NULL,
    [filtered_records]  INT            NULL,
    [total_records]     INT            NULL,
    [sql_to_exec]       NVARCHAR (MAX) NULL,
    [transaction_name]  NVARCHAR (500) NULL,
    [transaction_start] DATETIME       DEFAULT (getdate()) NOT NULL,
    [transaction_end]   DATETIME       NULL,
    [commited]          BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ctldID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'транзакция зафиксирована', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'commited';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'конец транзакции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'transaction_end';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'начало транзакции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'transaction_start';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя транзакции', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'transaction_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'sql запрос', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'sql_to_exec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'всего строк', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'total_records';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'отфильтровано строк', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'filtered_records';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'поле фильтра', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'filter_field';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'автоинкрементное поле', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'inc_field';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'table_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'внешний ключ на [srv].[_cleaning_tables_log]', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log_det', @level2type = N'COLUMN', @level2name = N'ctlID';

