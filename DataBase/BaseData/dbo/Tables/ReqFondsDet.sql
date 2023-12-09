CREATE TABLE [dbo].[ReqFondsDet] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [reqnum]  INT             NULL,
    [code]    INT             NULL,
    [saldo]   NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [nd]      DATETIME        NULL,
    [summa]   NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [comment] VARCHAR (512)   NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

