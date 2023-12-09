CREATE TABLE [dbo].[SRep_Prod] (
    [DateProd] INT             NULL,
    [Nnak]     INT             NULL,
    [B_Id]     INT             NULL,
    [Fam]      VARCHAR (35)    NULL,
    [Hitag]    INT             NULL,
    [Kol]      INT             NULL,
    [Cost]     MONEY           NULL,
    [Price]    MONEY           NULL,
    [Extra]    FLOAT (53)      NULL,
    [Ncod]     INT             NULL,
    [MinP]     INT             NULL,
    [Weight]   DECIMAL (10, 3) NULL
);


GO
CREATE NONCLUSTERED INDEX [SRepProd_Hitag_idx]
    ON [dbo].[SRep_Prod]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [SRepProd_Bid_idx]
    ON [dbo].[SRep_Prod]([B_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [SRepProd_DateProd_idx]
    ON [dbo].[SRep_Prod]([DateProd] ASC);

