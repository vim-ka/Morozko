CREATE TABLE [dbo].[DovOut] (
    [DovOutID]    INT          IDENTITY (1, 1) NOT NULL,
    [DovNomStart] VARCHAR (20) NULL,
    [DovNomEnd]   VARCHAR (20) NULL,
    [ND]          DATETIME     NULL,
    [OP]          INT          NULL,
    [Our_ID]      INT          NULL,
    [ag_id]       INT          NULL,
    [NDBeg]       DATETIME     NULL,
    [NDEnd]       DATETIME     NULL,
    [Remark]      VARCHAR (70) NULL,
    [NDReturn]    DATETIME     NULL,
    [p_id]        INT          NULL,
    CONSTRAINT [DovOut_pk] PRIMARY KEY CLUSTERED ([DovOutID] ASC),
    CONSTRAINT [UQ__DovOut__5F97284BCCEA1588] UNIQUE NONCLUSTERED ([DovOutID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DovOut_idx2]
    ON [dbo].[DovOut]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [DovOut_idx]
    ON [dbo].[DovOut]([ag_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата возврата корешка доверенностей', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DovOut', @level2type = N'COLUMN', @level2name = N'NDReturn';

