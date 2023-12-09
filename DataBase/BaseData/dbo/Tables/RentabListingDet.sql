CREATE TABLE [dbo].[RentabListingDet] (
    [id]       INT      IDENTITY (1, 1) NOT NULL,
    [lmid]     INT      NULL,
    [code]     INT      NULL,
    [datefrom] DATETIME NULL,
    [dateto]   DATETIME NULL,
    [stat]     BIT      DEFAULT ((1)) NULL,
    [tip]      INT      DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 - товары, 2 - поставщики, 3 - тов. категории', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingDet', @level2type = N'COLUMN', @level2name = N'tip';

