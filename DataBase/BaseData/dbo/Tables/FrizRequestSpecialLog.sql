CREATE TABLE [dbo].[FrizRequestSpecialLog] (
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
    [operator]     INT          NULL,
    [nd]           DATETIME     NULL,
    [action]       VARCHAR (3)  NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

