CREATE TABLE [dbo].[reqlinkbudgetst] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [reqnum]    INT             NULL,
    [linkrbdet] INT             NULL,
    [linksum]   NUMERIC (10, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [reqlinkbudgetst_idx]
    ON [dbo].[reqlinkbudgetst]([reqnum] ASC);

