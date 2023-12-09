CREATE TABLE [RetroB].[BasFondRe] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [bpmid]      INT             NULL,
    [delta]      NUMERIC (15, 2) NULL,
    [deltawonds] NUMERIC (15, 2) NULL,
    [nd]         DATETIME        DEFAULT ([dbo].[today]()) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

