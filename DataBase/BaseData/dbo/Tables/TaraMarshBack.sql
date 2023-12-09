CREATE TABLE [dbo].[TaraMarshBack] (
    [tmId]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME     DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]      CHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [MarshND] DATETIME     NULL,
    [Marsh]   INT          NULL,
    [B_id]    INT          NULL,
    [Kol]     INT          NULL,
    [Op]      INT          NULL,
    [Remark]  VARCHAR (25) NULL,
    CONSTRAINT [TaraMarshBack_pk] PRIMARY KEY CLUSTERED ([tmId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraMarshBack', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во возвращенной тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraMarshBack', @level2type = N'COLUMN', @level2name = N'Kol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraMarshBack', @level2type = N'COLUMN', @level2name = N'Marsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraMarshBack', @level2type = N'COLUMN', @level2name = N'MarshND';

