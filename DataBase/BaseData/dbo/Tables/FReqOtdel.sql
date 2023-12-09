CREATE TABLE [dbo].[FReqOtdel] (
    [reqnum]       INT             IDENTITY (1, 1) NOT NULL,
    [dep]          INT             NULL,
    [year]         INT             NULL,
    [month]        INT             NULL,
    [nprobeg]      NUMERIC (5, 2)  CONSTRAINT [DF__FReqOtdel__nprob__28063D95] DEFAULT ((0)) NULL,
    [summa]        NUMERIC (10, 2) CONSTRAINT [DF__FReqOtdel__summa__28FA61CE] DEFAULT ((0)) NULL,
    [depchiefdate] DATETIME        NULL,
    CONSTRAINT [UQ__FReqOtde__0551A81F2C2D3077] UNIQUE NONCLUSTERED ([reqnum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nprobeg - неподтвержденный пробег в процентах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqOtdel';

