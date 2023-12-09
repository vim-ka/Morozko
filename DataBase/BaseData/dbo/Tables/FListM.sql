CREATE TABLE [dbo].[FListM] (
    [flID]        INT           IDENTITY (1, 1) NOT NULL,
    [fluin]       INT           NULL,
    [florg]       INT           NULL,
    [fdolzh]      VARCHAR (200) NULL,
    [fdate]       DATETIME      NULL,
    [flAuto]      VARCHAR (40)  NULL,
    [flAutoNum]   VARCHAR (30)  NULL,
    [flAutoNorma] INT           NULL,
    [p_id]        INT           NULL,
    UNIQUE NONCLUSTERED ([flID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'список для печати маршрутных листов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FListM';

