CREATE TABLE [RetroB].[Rb_RAW] (
    [rawID]      INT              IDENTITY (1, 1) NOT NULL,
    [vedID]      INT              NOT NULL,
    [datnom]     BIGINT           NOT NULL,
    [tekid]      INT              NULL,
    [Hitag]      INT              NOT NULL,
    [b_id]       INT              NULL,
    [Master]     INT              NULL,
    [Kol]        INT              NULL,
    [Cost]       DECIMAL (15, 5)  NULL,
    [Nds]        DECIMAL (4, 1)   CONSTRAINT [DF__Rb_RAW__Nds__2752107E_copy] DEFAULT ((18)) NULL,
    [Price]      DECIMAL (15, 5)  NULL,
    [PayKoeff]   DECIMAL (15, 10) CONSTRAINT [DF__Rb_RAW__PayKoeff__48B30449_copy] DEFAULT ((0)) NULL,
    [Ncod]       INT              NOT NULL,
    [Ngrp]       INT              NOT NULL,
    [MainParent] INT              NOT NULL,
    [DCK]        INT              NULL,
    [Ag_ID]      INT              NULL,
    [Sv_ID]      INT              NULL,
    [DepID]      SMALLINT         NULL,
    [Our_ID]     SMALLINT         NULL,
    [Weight]     DECIMAL (10, 3)  DEFAULT ((0)) NULL,
    CONSTRAINT [PK__Rb_RAW__86EFBD737B0E66BC_copy] PRIMARY KEY CLUSTERED ([rawID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Rb_RAW_idx]
    ON [RetroB].[Rb_RAW]([vedID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Связь с rb_Main', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'Rb_RAW', @level2type = N'COLUMN', @level2name = N'vedID';

