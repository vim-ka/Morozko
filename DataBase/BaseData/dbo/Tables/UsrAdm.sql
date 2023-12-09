CREATE TABLE [dbo].[UsrAdm] (
    [UsrPrgID]  INT      NOT NULL,
    [usrPwdID]  INT      NOT NULL,
    [AccessDen] SMALLINT DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([UsrPrgID] ASC),
    UNIQUE NONCLUSTERED ([usrPwdID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'разрешен ли доступ в программу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsrAdm', @level2type = N'COLUMN', @level2name = N'AccessDen';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пороли логины', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsrAdm', @level2type = N'COLUMN', @level2name = N'usrPwdID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя вызываемой программы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsrAdm', @level2type = N'COLUMN', @level2name = N'UsrPrgID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доступ пользователей к внутренним программам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsrAdm';

