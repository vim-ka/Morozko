CREATE TABLE [dbo].[TaraDet] (
    [tdid]       INT          IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME     NULL,
    [Tm]         VARCHAR (8)  DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [B_ID]       INT          NULL,
    [Nnak]       INT          NULL,
    [SellDate]   DATETIME     NULL,
    [DatNom]     BIGINT       NULL,
    [ACT]        VARCHAR (2)  NULL,
    [taratip]    TINYINT      CONSTRAINT [DF__TaraDet___taratip__18EBB532_TaraDet_n2] DEFAULT ((1)) NULL,
    [Kol]        INT          NULL,
    [Price]      MONEY        NULL,
    [OP]         SMALLINT     NULL,
    [naktip]     TINYINT      CONSTRAINT [DF__TaraDet___naktip__17F790F9_TaraDet_n2] DEFAULT ((0)) NULL,
    [tarid]      INT          NULL,
    [Remark]     VARCHAR (60) NULL,
    [RealDatNom] BIGINT       CONSTRAINT [DF__TaraDet__RealDat__7B271378] DEFAULT ((0)) NULL,
    [DCK]        INT          NULL,
    PRIMARY KEY CLUSTERED ([tdid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DatNom реальной накладной (продажной или возвратной)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraDet', @level2type = N'COLUMN', @level2name = N'RealDatNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DatNom продажной накладной по которой идет продажа или возврат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaraDet', @level2type = N'COLUMN', @level2name = N'DatNom';

