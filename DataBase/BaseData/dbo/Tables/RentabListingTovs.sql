CREATE TABLE [dbo].[RentabListingTovs] (
    [id]       INT      IDENTITY (1, 1) NOT NULL,
    [lmid]     INT      NULL,
    [hitag]    INT      NULL,
    [datefrom] DATETIME NULL,
    [dateto]   DATETIME NULL,
    [tip]      INT      NULL,
    [ncod]     INT      DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'товары, по которым должны быть оплаты и возмещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingTovs';

