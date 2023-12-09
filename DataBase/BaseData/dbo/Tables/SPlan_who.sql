CREATE TABLE [dbo].[SPlan_who] (
    [Smid]    INT NULL,
    [Pin]     INT NULL,
    [Lvl]     INT DEFAULT ((0)) NULL,
    [NetFlag] BIT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для покупателей. 0-одиночный, 1-сеть', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPlan_who', @level2type = N'COLUMN', @level2name = N'NetFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип: 0-отдел 1-суперв. 2-агент 3-покуп.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPlan_who', @level2type = N'COLUMN', @level2name = N'Lvl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела/супервайзера/агента/покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPlan_who', @level2type = N'COLUMN', @level2name = N'Pin';

