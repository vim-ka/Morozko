CREATE TABLE [dbo].[TransKassa] (
    [Person]  NUMERIC (18)    NULL,
    [Client]  NUMERIC (18)    NULL,
    [Summa]   NUMERIC (18, 2) NULL,
    [CodOper] INT             NULL,
    [ID]      NUMERIC (10)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [TransKassa_uq] UNIQUE NONCLUSTERED ([ID] ASC)
);

