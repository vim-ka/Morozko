CREATE TABLE [dbo].[RemToRtrn] (
    [IDrm]       INT          IDENTITY (1, 1) NOT NULL,
    [SourDatNom] BIGINT       NULL,
    [DatNom]     BIGINT       NULL,
    [ND]         DATETIME     CONSTRAINT [DF__RemToRtrn__ND__5ACF527F] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]         CHAR (8)     CONSTRAINT [DF__RemToRtrn__TM__69F19A7E] DEFAULT (CONVERT([varchar],getdate(),(8))) NULL,
    [Nnak]       INT          NULL,
    [ID]         INT          NULL,
    [Hitag]      INT          NULL,
    [Remark]     VARCHAR (80) NULL,
    [Reason_Id]  INT          NULL,
    [Note]       VARCHAR (80) NULL,
    [Tip]        SMALLINT     NULL,
    [NCId]       INT          NULL,
    [svCompl]    DATETIME     NULL,
    [bhCompl]    DATETIME     NULL,
    [Date]       DATETIME     NULL,
    [Comp]       VARCHAR (30) DEFAULT (host_name()) NULL,
    CONSTRAINT [RemToRtrn_pk] PRIMARY KEY CLUSTERED ([IDrm] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RemToRtrn_idx2]
    ON [dbo].[RemToRtrn]([DatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [RemToRtrn_idx3]
    ON [dbo].[RemToRtrn]([SourDatNom] ASC);


GO
CREATE NONCLUSTERED INDEX [RemToRtrn_idx]
    ON [dbo].[RemToRtrn]([SourDatNom] ASC, [DatNom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Датном возвратной накладной, для исправленных накладных будет равен SourDatNom', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RemToRtrn', @level2type = N'COLUMN', @level2name = N'DatNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Датном исходной накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RemToRtrn', @level2type = N'COLUMN', @level2name = N'SourDatNom';

