CREATE TABLE [dbo].[Def_FormatErmann] (
    [pin]    INT          NOT NULL,
    [dfid]   INT          DEFAULT ((39)) NULL,
    [remark] VARCHAR (60) NULL,
    CONSTRAINT [Def_FormatErmann_pk] PRIMARY KEY CLUSTERED ([pin] ASC)
);

