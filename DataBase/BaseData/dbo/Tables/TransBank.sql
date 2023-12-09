CREATE TABLE [dbo].[TransBank] (
    [ID]          NUMERIC (15)    IDENTITY (1, 1) NOT NULL,
    [ActDate]     DATETIME        NULL,
    [B_ID]        CHAR (20)       NULL,
    [Summa]       NUMERIC (18, 2) NULL,
    [SummaRashod] NUMERIC (18, 2) NULL,
    [Bank_ID]     NUMERIC (15)    NULL,
    [Remark]      CHAR (40)       NULL,
    [CName]       VARCHAR (100)   NULL,
    [CKod]        NUMERIC (10)    NULL,
    [Rshet]       VARCHAR (20)    NULL,
    [RemarkPlat]  NCHAR (150)     NULL,
    [Our_ID]      INT             NULL,
    [OP]          INT             DEFAULT ((0)) NULL,
    [datnom]      INT             DEFAULT ((0)) NULL,
    [commiss]     BIT             DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TransBank] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [TransBank_uq] UNIQUE NONCLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'комиссия банка по факторингу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransBank', @level2type = N'COLUMN', @level2name = N'commiss';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransBank', @level2type = N'COLUMN', @level2name = N'datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransBank', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фирма с нашей стороны', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransBank', @level2type = N'COLUMN', @level2name = N'Our_ID';

