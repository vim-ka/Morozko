CREATE TABLE [dbo].[AddrBind] (
    [abk]      INT        IDENTITY (1, 1) NOT NULL,
    [Ncod]     INT        NOT NULL,
    [AddrID]   INT        NULL,
    [skg]      INT        NOT NULL,
    [RStorage] INT        NOT NULL,
    [Level]    TINYINT    NOT NULL,
    [Index]    TINYINT    CONSTRAINT [DF__AddrBind__Index__7C7B2A64] DEFAULT ((0)) NOT NULL,
    [NLine]    TINYINT    NOT NULL,
    [Depth]    TINYINT    CONSTRAINT [DF__AddrBind__Depth__7D6F4E9D] DEFAULT ((1)) NOT NULL,
    [Volum]    FLOAT (53) NULL,
    UNIQUE NONCLUSTERED ([abk] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'связные адреса7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddrBind', @level2type = N'COLUMN', @level2name = N'abk';

