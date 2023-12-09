CREATE TABLE [dbo].[BlackVendList] (
    [B_ID]  INT     NULL,
    [Ncod]  INT     NULL,
    [Disab] TINYINT NULL,
    CONSTRAINT [BlackVendList_uq] UNIQUE NONCLUSTERED ([B_ID] ASC, [Ncod] ASC)
);

