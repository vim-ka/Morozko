CREATE TABLE [dbo].[Sertif] (
    [sert_id] INT          DEFAULT ([dbo].[NewSert_id]()) NOT NULL,
    [orgName] VARCHAR (80) NULL,
    [nSert]   VARCHAR (40) DEFAULT ('РОСС RU') NULL,
    [nBlank]  VARCHAR (15) NULL,
    [begDate] DATETIME     NULL,
    [endDate] DATETIME     NULL,
    [nVet]    VARCHAR (15) DEFAULT ('236/') NULL,
    [dateVet] DATETIME     NULL,
    [PersOtv] VARCHAR (50) NULL,
    [IDRow]   INT          NULL,
    [isDel]   BIT          DEFAULT ((0)) NOT NULL,
    [id_org]  INT          NULL,
    [id_otv]  INT          NULL,
    CONSTRAINT [Sertif_uq_copy] UNIQUE NONCLUSTERED ([sert_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Sertif_idx]
    ON [dbo].[Sertif]([sert_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'лицо принявшее декларацию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Sertif', @level2type = N'COLUMN', @level2name = N'PersOtv';

