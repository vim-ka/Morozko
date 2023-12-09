CREATE TABLE [dbo].[RentabListingMain] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [pin]        INT             NULL,
    [isnet]      BIT             DEFAULT ((0)) NULL,
    [sum_opl]    NUMERIC (10, 2) NULL,
    [sum_vozm]   NUMERIC (10, 2) NULL,
    [datefrom]   DATETIME        NULL,
    [dateto]     DATETIME        NULL,
    [urlica]     BIT             DEFAULT ((0)) NULL,
    [comment]    VARCHAR (512)   NULL,
    [tip_list]   SMALLINT        DEFAULT ((1)) NULL,
    [soglfindir] BIT             DEFAULT ((0)) NULL,
    [sent]       BIT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип контракта: 0 - листинг, 1 - оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingMain', @level2type = N'COLUMN', @level2name = N'tip_list';

