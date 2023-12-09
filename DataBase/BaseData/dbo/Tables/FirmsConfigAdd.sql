CREATE TABLE [dbo].[FirmsConfigAdd] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [our_id]          INT           NULL,
    [fio]             VARCHAR (128) NULL,
    [fio_rp]          VARCHAR (128) NULL,
    [osn_rp]          VARCHAR (64)  NULL,
    [email]           VARCHAR (64)  NULL,
    [email_buh]       VARCHAR (64)  NULL,
    [ogrn_pref]       VARCHAR (16)  NULL,
    [dovernum]        VARCHAR (30)  NULL,
    [doverdate]       DATETIME      NULL,
    [doverdatebefore] DATETIME      NULL,
    [doc_pref]        VARCHAR (16)  NULL,
    [tipdocform]      VARCHAR (5)   NULL,
    [tipdocformnd]    DATETIME      NULL,
    [prikaznum]       VARCHAR (10)  NULL,
    [prikazdate]      DATETIME      NULL,
    [prikaznaklnum]   VARCHAR (10)  NULL,
    [prikaznakldate]  DATETIME      NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'префикс ОГРН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'ogrn_pref';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'адрес бухгалтерии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'email_buh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'основной адрес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'основание род. падеж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'osn_rp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фамилия имя отчество род. падеж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'fio_rp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фамилия имя отчество', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsConfigAdd', @level2type = N'COLUMN', @level2name = N'fio';

