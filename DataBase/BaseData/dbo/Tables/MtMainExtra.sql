CREATE TABLE [dbo].[MtMainExtra] (
    [MeID]  INT        IDENTITY (1, 1) NOT NULL,
    [NDBeg] DATETIME   NULL,
    [Op]    INT        NULL,
    [Hitag] INT        DEFAULT ((0)) NULL,
    [Ngrp]  INT        DEFAULT ((0)) NULL,
    [Ncod]  INT        DEFAULT ((0)) NULL,
    [B_ID]  INT        DEFAULT ((0)) NULL,
    [Ag_id] INT        DEFAULT ((0)) NULL,
    [Sv_id] INT        DEFAULT ((0)) NULL,
    [DepID] INT        DEFAULT ((0)) NULL,
    [Extra] FLOAT (53) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([MeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка на Cost в %', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MtMainExtra', @level2type = N'COLUMN', @level2name = N'Extra';

