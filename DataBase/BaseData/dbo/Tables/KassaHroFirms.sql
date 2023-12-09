CREATE TABLE [dbo].[KassaHroFirms] (
    [KhFID]    INT      IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME NULL,
    [Our_ID]   INT      NULL,
    [KassMorn] MONEY    NULL,
    CONSTRAINT [KassaHroFirms_pk] PRIMARY KEY CLUSTERED ([KhFID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [KassaHroFirms_idx2]
    ON [dbo].[KassaHroFirms]([Our_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [KassaHroFirms_idx]
    ON [dbo].[KassaHroFirms]([ND] ASC);

