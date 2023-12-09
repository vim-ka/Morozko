CREATE TABLE [dbo].[NEW_Visual] (
    [id]         INT             NOT NULL,
    [startid]    INT             NULL,
    [ncom]       INT             NULL,
    [ncod]       INT             NULL,
    [datepost]   DATETIME        NULL,
    [Price]      DECIMAL (13, 5) NULL,
    [start]      DECIMAL (12, 3) NULL,
    [startthis]  DECIMAL (12, 3) NULL,
    [hitag]      INT             NULL,
    [sklad]      SMALLINT        NULL,
    [cost]       DECIMAL (13, 5) NULL,
    [nalog5]     TINYINT         DEFAULT ((0)) NULL,
    [minp]       INT             DEFAULT ((1)) NULL,
    [mpu]        INT             DEFAULT ((1)) NULL,
    [sert_id]    INT             NULL,
    [rang]       CHAR (1)        NULL,
    [now]        NUMERIC (8)     CONSTRAINT [DF__Visual__MORN__21D600EE_copy] DEFAULT ((0)) NULL,
    [isprav]     DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [remov]      DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [bad]        DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [dater]      DATETIME        NULL,
    [srokh]      DATETIME        NULL,
    [country]    VARCHAR (15)    NULL,
    [rezerv]     DECIMAL (12, 3) NULL,
    [units]      VARCHAR (3)     NULL,
    [locked]     BIT             NULL,
    [ncountry]   DECIMAL (3)     NULL,
    [gtd]        VARCHAR (100)   NULL,
    [vitr]       DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [our_id]     SMALLINT        DEFAULT ((7)) NULL,
    [weight]     DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [baseprice]  MONEY           NULL,
    [LastDate]   DATETIME        NULL,
    [morn]       NUMERIC (6)     NULL,
    [sell]       NUMERIC (6)     NULL,
    [MeasId]     TINYINT         DEFAULT ((2)) NULL,
    [ncnt]       INT             NULL,
    [DCK]        INT             NULL,
    [wsid]       TINYINT         DEFAULT ((1)) NULL,
    [CountryID]  INT             NULL,
    [ProducerID] INT             NULL,
    [pin]        INT             NULL,
    [UnID]       TINYINT         DEFAULT ((0)) NOT NULL,
    [Unid2]      TINYINT         DEFAULT ((0)) NOT NULL,
    [KU]         DECIMAL (14, 7) DEFAULT ((1.0)) NOT NULL,
    CONSTRAINT [Visual_pk_copy] PRIMARY KEY NONCLUSTERED ([id] ASC),
    CONSTRAINT [Visual_uq_copy] UNIQUE CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Visual_idx4]
    ON [dbo].[NEW_Visual]([ncom] ASC);


GO
CREATE NONCLUSTERED INDEX [Visual_idx3]
    ON [dbo].[NEW_Visual]([id] ASC);


GO
CREATE NONCLUSTERED INDEX [Visual_idx2]
    ON [dbo].[NEW_Visual]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [Visual_idx]
    ON [dbo].[NEW_Visual]([ncod] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ед.изм.табл.Units', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Visual', @level2type = N'COLUMN', @level2name = N'UnID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Visual', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Единицы измерения по умолчанию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Visual', @level2type = N'COLUMN', @level2name = N'MeasId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удалить Morn из W_A4, потом отсюда', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Visual', @level2type = N'COLUMN', @level2name = N'morn';

