CREATE TABLE [dbo].[ReqBrakDet] (
    [id]      INT           IDENTITY (1, 1) NOT NULL,
    [reqnum]  INT           NULL,
    [btip]    INT           NULL,
    [hitag]   INT           NULL,
    [comment] VARCHAR (512) NULL,
    [nnak]    INT           NULL,
    [ndate]   DATETIME      NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

