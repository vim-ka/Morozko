CREATE TABLE [dbo].[FrizerLoc] (
    [nd]   DATETIME NULL,
    [nom]  INT      NULL,
    [b_id] INT      NULL
);


GO
CREATE NONCLUSTERED INDEX [FrizerLoc_BID_idx]
    ON [dbo].[FrizerLoc]([b_id] ASC);


GO
CREATE NONCLUSTERED INDEX [FrizerLoc_Nd_idx]
    ON [dbo].[FrizerLoc]([nd] ASC);


GO
CREATE CLUSTERED INDEX [FrizerLoc_Nom_idx]
    ON [dbo].[FrizerLoc]([nom] ASC);

