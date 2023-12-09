CREATE TABLE [dbo].[helptable] (
    [id]           INT           IDENTITY (1000, 1) NOT NULL,
    [help_url]     VARCHAR (MAX) NULL,
    [help_comment] VARCHAR (128) NULL,
    CONSTRAINT [UQ__helptabl__3213E83E5E02B4AC] UNIQUE NONCLUSTERED ([id] ASC)
);

