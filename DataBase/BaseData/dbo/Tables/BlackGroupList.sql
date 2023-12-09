CREATE TABLE [dbo].[BlackGroupList] (
    [RecId]   INT           IDENTITY (1, 1) NOT NULL,
    [obl_id]  INT           NULL,
    [Rn_id]   INT           NULL,
    [DepId]   INT           NULL,
    [Sv_id]   INT           NULL,
    [Ag_id]   INT           NULL,
    [pin]     INT           NULL,
    [ncod]    INT           NOT NULL,
    [ngrp]    INT           NULL,
    [hitag]   INT           NULL,
    [Disab]   BIT           NULL,
    [ND]      DATETIME      NULL,
    [NDStart] DATETIME      NULL,
    [NDEnd]   DATETIME      NULL,
    [OP]      INT           NULL,
    [Remark]  VARCHAR (150) NULL,
    CONSTRAINT [BlackGroupList_pk] PRIMARY KEY CLUSTERED ([RecId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'NDEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'NDStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания запрета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заблокировано', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'Disab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Товарная группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'ngrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поставщик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Агент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'Ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Супервайзер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'Sv_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'DepId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Район', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'Rn_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Область', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BlackGroupList', @level2type = N'COLUMN', @level2name = N'obl_id';

