CREATE TABLE [dbo].[FFuelTipPrice] (
    [ftid]   INT          IDENTITY (1, 1) NOT NULL,
    [ftname] VARCHAR (20) NULL,
    [ftcost] MONEY        NULL,
    [ftdate] DATETIME     NULL,
    [fftip]  INT          NOT NULL
);

