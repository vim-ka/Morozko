CREATE TABLE [dbo].[TransBankOther] (
    [ID]          NUMERIC (15)    IDENTITY (1, 1) NOT NULL,
    [ActDate]     DATETIME        NULL,
    [B_ID]        CHAR (20)       NULL,
    [Summa]       NUMERIC (18, 2) NULL,
    [SummaRashod] NUMERIC (18, 2) NULL,
    [Bank_ID]     NUMERIC (15)    NULL,
    [Remark]      CHAR (40)       NULL,
    [CName]       VARCHAR (100)   NULL,
    [CKod]        CHAR (10)       NULL,
    [Rshet]       VARCHAR (20)    NULL,
    [RemarkPlat]  NCHAR (150)     NULL,
    [Completed]   BIT             CONSTRAINT [DF__TransBank__Compl__79BEB94A] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TransBankOther] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [TransBankOther_uq] UNIQUE NONCLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Обработана', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransBankOther', @level2type = N'COLUMN', @level2name = N'Completed';

