CREATE TABLE [dbo].[SertifVetSvid] (
    [Id_vet_svid]    INT            IDENTITY (1, 1) NOT NULL,
    [Id_var]         INT            NOT NULL,
    [Id_org]         INT            NOT NULL,
    [N_vet_svid]     VARCHAR (50)   NULL,
    [Date_vet_svid]  DATETIME       NULL,
    [N_str]          VARCHAR (100)  NULL,
    [Lab_issl]       VARCHAR (8000) NULL,
    [Otm]            VARCHAR (256)  NULL,
    [Is_Del]         BIT            DEFAULT ((0)) NOT NULL,
    [Our_id]         INT            NULL,
    [Our_id2]        INT            NULL,
    [N_vet_svid2]    VARCHAR (50)   NULL,
    [Date_vet_svid2] DATETIME       NULL,
    CONSTRAINT [PK_SERTIFVETSVID] PRIMARY KEY NONCLUSTERED ([Id_vet_svid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Relationship_1_FK]
    ON [dbo].[SertifVetSvid]([Id_org] ASC);


GO
CREATE NONCLUSTERED INDEX [Relationship_5_FK]
    ON [dbo].[SertifVetSvid]([Id_var] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Справочник ветеринарных свидетельств', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifVetSvid';

