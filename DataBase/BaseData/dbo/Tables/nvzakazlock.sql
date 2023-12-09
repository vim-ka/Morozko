CREATE TABLE [dbo].[nvzakazlock] (
    [datnom]   BIGINT       NULL,
    [dt]       DATETIME     NULL,
    [terminal] INT          NULL,
    [op]       INT          NULL,
    [hitag]    INT          DEFAULT ((0)) NOT NULL,
    [comp]     VARCHAR (50) NULL,
    [nzID]     INT          DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [nvzakazlock_idx2]
    ON [dbo].[nvzakazlock]([terminal] ASC);


GO
CREATE NONCLUSTERED INDEX [nvzakazlock_idx]
    ON [dbo].[nvzakazlock]([datnom] ASC);

