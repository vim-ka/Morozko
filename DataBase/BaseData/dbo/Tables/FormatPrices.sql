CREATE TABLE [dbo].[FormatPrices] (
    [FpID]      INT             IDENTITY (1, 1) NOT NULL,
    [FormatID]  INT             NOT NULL,
    [Hitag]     INT             NOT NULL,
    [flgWeight] BIT             NULL,
    [BasePrice] DECIMAL (15, 5) NULL,
    PRIMARY KEY CLUSTERED ([FpID] ASC)
);

