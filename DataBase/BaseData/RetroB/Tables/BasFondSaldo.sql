CREATE TABLE [RetroB].[BasFondSaldo] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [fondid]    INT             NULL,
    [sum_plata] NUMERIC (15, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

