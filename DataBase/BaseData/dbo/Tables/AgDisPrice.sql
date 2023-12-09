CREATE TABLE [dbo].[AgDisPrice] (
    [dip]     INT      IDENTITY (1, 1) NOT NULL,
    [ag_id]   INT      NULL,
    [Ngrp]    INT      NULL,
    [Disable] BIT      NULL,
    [ND]      DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([dip] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запрет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgDisPrice', @level2type = N'COLUMN', @level2name = N'Disable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер группы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgDisPrice', @level2type = N'COLUMN', @level2name = N'Ngrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgDisPrice', @level2type = N'COLUMN', @level2name = N'ag_id';

