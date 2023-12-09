CREATE TABLE [dbo].[TransBankCard] (
    [ID]     INT             IDENTITY (1, 1) NOT NULL,
    [NAME]   CHAR (100)      NULL,
    [SUMMA]  NUMERIC (18, 2) NULL,
    [RSCHET] CHAR (20)       NULL,
    CONSTRAINT [PK_TransBankCard] PRIMARY KEY CLUSTERED ([ID] ASC)
);

