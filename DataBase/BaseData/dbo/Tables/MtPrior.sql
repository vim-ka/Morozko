CREATE TABLE [dbo].[MtPrior] (
    [mp]          INT          IDENTITY (1, 1) NOT NULL,
    [ND]          DATETIME     DEFAULT (getdate()) NULL,
    [Op]          INT          DEFAULT ((0)) NULL,
    [DepID]       INT          DEFAULT ((0)) NULL,
    [Sv_id]       INT          DEFAULT ((0)) NULL,
    [Ag_id]       INT          DEFAULT ((0)) NULL,
    [B_ID]        INT          DEFAULT ((0)) NULL,
    [NGRP]        INT          DEFAULT ((0)) NULL,
    [Hitag]       INT          DEFAULT ((0)) NULL,
    [LightEnable] BIT          CONSTRAINT [DF__MtPrior__LightEn__24E0837E] DEFAULT ((0)) NULL,
    [NamePrefix]  VARCHAR (3)  DEFAULT ('') NOT NULL,
    [Color]       VARCHAR (19) NULL,
    [ord]         INT          NULL,
    [clr]         INT          DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([mp] ASC)
);


GO
CREATE NONCLUSTERED INDEX [MtPrior_idx5]
    ON [dbo].[MtPrior]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [MtPrior_idx4]
    ON [dbo].[MtPrior]([DepID] ASC);


GO
CREATE NONCLUSTERED INDEX [MtPrior_idx3]
    ON [dbo].[MtPrior]([Ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [MtPrior_idx2]
    ON [dbo].[MtPrior]([Sv_id] ASC);


GO
CREATE NONCLUSTERED INDEX [MtPrior_idx]
    ON [dbo].[MtPrior]([DepID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MtPrior_uq]
    ON [dbo].[MtPrior]([DepID] ASC, [Hitag] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нужна ли подсветка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MtPrior', @level2type = N'COLUMN', @level2name = N'LightEnable';

