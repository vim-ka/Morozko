CREATE TABLE [dbo].[NEW_NVEdit] (
    [NVID]     INT             IDENTITY (1, 1) NOT NULL,
    [NCID]     INT             NULL,
    [ND]       DATETIME        DEFAULT ([dbo].[today]()) NULL,
    [Nnak]     INT             NULL,
    [DatNom]   BIGINT          NULL,
    [Tm]       CHAR (8)        DEFAULT ([dbo].[time]()) NULL,
    [ID]       INT             NULL,
    [Hitag]    INT             NULL,
    [Price]    MONEY           NULL,
    [Cost]     NUMERIC (15, 5) NULL,
    [Nalog5]   TINYINT         NULL,
    [Kol]      NUMERIC (8, 2)  NULL,
    [NewKol]   NUMERIC (8, 2)  NULL,
    [SkladNo]  SMALLINT        NULL,
    [NewPrice] MONEY           NULL,
    [AddOp]    INT             NULL,
    PRIMARY KEY CLUSTERED ([NVID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nvedit_ncid_idx]
    ON [dbo].[NEW_NVEdit]([NCID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Связь с таблицей NcEdit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_NVEdit', @level2type = N'INDEX', @level2name = N'nvedit_ncid_idx';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Исправленная цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_NVEdit', @level2type = N'COLUMN', @level2name = N'NewPrice';

