CREATE TABLE [dbo].[AgAddBases] (
    [aaid]      INT      IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME CONSTRAINT [DF__AgAddBases__nd__27C57B1C] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]        CHAR (8) CONSTRAINT [DF__AgAddBases__tm__28B99F55] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [op]        INT      NULL,
    [ag_id]     INT      NULL,
    [add_ag_id] INT      NULL,
    [add_Dck]   INT      CONSTRAINT [DF__AgAddBase__add_D__26D156E3] DEFAULT ((0)) NULL,
    [p_id1]     INT      NULL,
    [add_P_id1] INT      CONSTRAINT [DF__AgAddBase__add_P__25DD32AA] DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([aaid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [AgAddBases_idx3]
    ON [dbo].[AgAddBases]([add_Dck] ASC);


GO
CREATE NONCLUSTERED INDEX [AgAddBases_idx2]
    ON [dbo].[AgAddBases]([add_ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [AgAddBases_idx]
    ON [dbo].[AgAddBases]([ag_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'всю базу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgAddBases', @level2type = N'COLUMN', @level2name = N'add_P_id1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кому добавляем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgAddBases', @level2type = N'COLUMN', @level2name = N'p_id1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'или конкретного контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgAddBases', @level2type = N'COLUMN', @level2name = N'add_Dck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кто добавил', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgAddBases', @level2type = N'COLUMN', @level2name = N'op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'когда добавили', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgAddBases', @level2type = N'COLUMN', @level2name = N'nd';

