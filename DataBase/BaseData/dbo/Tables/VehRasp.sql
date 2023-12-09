CREATE TABLE [dbo].[VehRasp] (
    [vr]        INT         IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME    DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [tm]        VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Op]        INT         NULL,
    [V_ID]      INT         NULL,
    [PlanDay]   DATETIME    NULL,
    [Available] BIT         DEFAULT ((1)) NULL,
    [tmWork]    CHAR (5)    NULL,
    [Reserve]   TINYINT     DEFAULT ((0)) NULL,
    [DrID]      INT         DEFAULT ((0)) NULL,
    [RaspType]  SMALLINT    NULL,
    UNIQUE NONCLUSTERED ([vr] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [VehRasp_uq]
    ON [dbo].[VehRasp]([PlanDay] ASC, [V_ID] ASC, [DrID] ASC);


GO
CREATE NONCLUSTERED INDEX [VehRasp_idx3]
    ON [dbo].[VehRasp]([DrID] ASC);


GO
CREATE NONCLUSTERED INDEX [VehRasp_idx2]
    ON [dbo].[VehRasp]([V_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [VehRasp_idx]
    ON [dbo].[VehRasp]([PlanDay] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-запасной водитель(машина) ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehRasp', @level2type = N'COLUMN', @level2name = N'Reserve';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'примерное время начала загрузки машины', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehRasp', @level2type = N'COLUMN', @level2name = N'tmWork';

