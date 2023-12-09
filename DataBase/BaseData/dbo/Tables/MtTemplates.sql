CREATE TABLE [dbo].[MtTemplates] (
    [pin]   INT NULL,
    [hitag] INT NULL,
    CONSTRAINT [MtTemplates_uq] UNIQUE CLUSTERED ([pin] ASC, [hitag] ASC)
);

