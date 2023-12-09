CREATE TABLE [dbo].[MarketRequestSlot] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [mrid]     INT             NULL,
    [tip]      INT             DEFAULT ((1)) NULL,
    [minvkol]  INT             DEFAULT ((0)) NULL,
    [minvrub]  NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [minvkg]   NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [allvkol]  INT             DEFAULT ((0)) NULL,
    [allvrub]  NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [allvkg]   NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [tempUID]  INT             NULL,
    [minvkolm] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [allvkolm] NUMERIC (12, 2) DEFAULT ((0)) NULL,
    [isall]    AS              (case when (((isnull([allvkol],(0))+isnull([allvrub],(0)))+isnull([allvkg],(0)))+isnull([allvkolm],(0)))>(0) then (1) else (0) end) PERSISTED NOT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вычисляемое поле для определения, по какому принципу считать данные по акции: 1 - по общему количеству, 0 - по каждому товару', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestSlot', @level2type = N'COLUMN', @level2name = N'isall';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 - условие И, 2 - условие ИЛИ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestSlot', @level2type = N'COLUMN', @level2name = N'tip';

