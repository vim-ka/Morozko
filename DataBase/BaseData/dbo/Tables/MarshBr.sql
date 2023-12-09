CREATE TABLE [dbo].[MarshBr] (
    [mbid]   INT   IDENTITY (1, 1) NOT NULL,
    [mhid]   INT   NOT NULL,
    [b_id]   INT   NOT NULL,
    [ForGet] MONEY NULL,
    PRIMARY KEY CLUSTERED ([mbid] ASC)
);

