CREATE TABLE [dbo].[MarketRequestSuper] (
    [id]   INT IDENTITY (1, 1) NOT NULL,
    [mrid] INT NULL,
    [p_id] INT NULL,
    [tip]  INT DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-агент
2-супервайзер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestSuper', @level2type = N'COLUMN', @level2name = N'tip';

