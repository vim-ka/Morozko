CREATE TABLE [dbo].[MarketRequestSlotMeh] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [mrid]      INT             NULL,
    [slotid]    INT             NULL,
    [planval]   NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [tip]       INT             DEFAULT ((0)) NULL,
    [once]      BIT             DEFAULT ((1)) NULL,
    [anysku]    BIT             DEFAULT ((1)) NULL,
    [bonus]     BIT             DEFAULT ((0)) NULL,
    [minskukol] INT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - шт.
1 - кор.
2 - руб.
3 - кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestSlotMeh', @level2type = N'COLUMN', @level2name = N'tip';

