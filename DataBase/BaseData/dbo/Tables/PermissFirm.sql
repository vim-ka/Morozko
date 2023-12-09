CREATE TABLE [dbo].[PermissFirm] (
    [Uin]       INT NOT NULL,
    [Prg]       INT NOT NULL,
    [FirmGroup] INT NOT NULL,
    [pfID]      INT IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PermissFirm_uq] UNIQUE NONCLUSTERED ([pfID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер разрешенной группы фирм', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PermissFirm', @level2type = N'COLUMN', @level2name = N'FirmGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ программы, например, 2-продажи и т.д.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PermissFirm', @level2type = N'COLUMN', @level2name = N'Prg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора, см. UsrPWD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PermissFirm', @level2type = N'COLUMN', @level2name = N'Uin';

