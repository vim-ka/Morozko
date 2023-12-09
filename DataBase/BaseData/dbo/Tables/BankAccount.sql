CREATE TABLE [dbo].[BankAccount] (
    [BID]     INT      IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME NULL,
    [Bank_ID] INT      NULL,
    [SumAc]   MONEY    NULL,
    CONSTRAINT [PK__BankAcco__C6DE0D21860D454B] PRIMARY KEY CLUSTERED ([BID] ASC),
    CONSTRAINT [BankAccount_uq] UNIQUE NONCLUSTERED ([ND] ASC, [Bank_ID] ASC)
);

