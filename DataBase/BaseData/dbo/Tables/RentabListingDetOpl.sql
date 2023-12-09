CREATE TABLE [dbo].[RentabListingDetOpl] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [lmid]     INT             NULL,
    [tip]      SMALLINT        NULL,
    [nd]       DATETIME        NULL,
    [summa]    NUMERIC (12, 2) NULL,
    [vid]      INT             NULL,
    [ord]      INT             NULL,
    [datefrom] DATETIME        NULL,
    [dateto]   DATETIME        NULL,
    [ncod]     INT             DEFAULT ((-1)) NULL,
    [ncod_tip] INT             DEFAULT ((1)) NULL,
    [linkreq]  INT             DEFAULT ((-1)) NULL,
    [fond]     INT             DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'порядок оплаты - из табл. rentablistingoplataord', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingDetOpl', @level2type = N'COLUMN', @level2name = N'ord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'способ оплаты, ссылка на таблицу rentablistingoplatavid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingDetOpl', @level2type = N'COLUMN', @level2name = N'vid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип: 1 - оплата листинга, 2 - возмещение листинга, 3 - оплата оборудования, 4 - возмещение оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingDetOpl', @level2type = N'COLUMN', @level2name = N'tip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на табл. rentablistingmain', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingDetOpl', @level2type = N'COLUMN', @level2name = N'lmid';

