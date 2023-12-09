CREATE TABLE [dbo].[FrizRequestSpecial] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [reqnum]       INT          NULL,
    [floor]        INT          NULL,
    [lift]         INT          NULL,
    [wheel]        INT          NULL,
    [meters]       INT          NULL,
    [doorsize]     VARCHAR (20) NULL,
    [datefree]     DATETIME     NULL,
    [mancount]     INT          NULL,
    [nonstandard]  INT          NULL,
    [transporttip] INT          NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

