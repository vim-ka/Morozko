CREATE TABLE [dbo].[FrizRequestInvNom] (
    [id]        INT IDENTITY (1, 1) NOT NULL,
    [frizreqid] INT NOT NULL,
    [frizernom] INT NOT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FrizRequestInvNom_idx2]
    ON [dbo].[FrizRequestInvNom]([frizernom] ASC);


GO
CREATE NONCLUSTERED INDEX [FrizRequestInvNom_idx]
    ON [dbo].[FrizRequestInvNom]([frizreqid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequestInvNom', @level2type = N'COLUMN', @level2name = N'frizernom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequestInvNom', @level2type = N'COLUMN', @level2name = N'frizreqid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'frizreqid - код заявки
frizernom - код из таблицы frizer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequestInvNom';

