CREATE TABLE [RetroB].[BasPrices] (
    [prid]      INT             IDENTITY (1, 1) NOT NULL,
    [BPMid]     INT             NOT NULL,
    [Hitag]     INT             NOT NULL,
    [BaseCost]  DECIMAL (15, 5) NULL,
    [FinalCost] DECIMAL (15, 5) NULL,
    [Day0]      DATETIME        NULL,
    [Day1]      DATETIME        NULL,
    [flgWeight] BIT             NULL,
    CONSTRAINT [BasPrices_fk] FOREIGN KEY ([BPMid]) REFERENCES [RetroB].[BasPricesMain] ([BPMid]) ON UPDATE CASCADE,
    CONSTRAINT [UQ__BasPrice__46638AEC07947D11] UNIQUE NONCLUSTERED ([prid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [BasPrices_idx2]
    ON [RetroB].[BasPrices]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [BasPrices_idx]
    ON [RetroB].[BasPrices]([BPMid] ASC);


GO
CREATE TRIGGER RetroB.BasPrices_trd ON RetroB.BasPrices
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  insert into BasPricesLog (prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, tip)
  select prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, 3 from inserted
END
GO
CREATE TRIGGER RetroB.BasPrices_tri ON RetroB.BasPrices
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  insert into BasPricesLog (prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, tip)
  select prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, 0 from inserted
END
GO
CREATE TRIGGER RetroB.BasPrices_tru ON RetroB.BasPrices
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  insert into BasPricesLog (prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, tip)
  select prid, BPMid, Hitag, BaseCost, FinalCost, Day0, Day1, flgWeight, 1 from inserted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена за 1 кг', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasPrices', @level2type = N'COLUMN', @level2name = N'flgWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Окончательная цена прихода', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasPrices', @level2type = N'COLUMN', @level2name = N'FinalCost';

