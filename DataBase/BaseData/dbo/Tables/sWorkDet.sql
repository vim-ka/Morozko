CREATE TABLE [dbo].[sWorkDet] (
    [wk]      INT      IDENTITY (1, 1) NOT NULL,
    [WorkID]  INT      NULL,
    [datnom]  INT      NULL,
    [hitag]   INT      NULL,
    [KolNeed] INT      NULL,
    [KolFact] INT      NULL,
    [ReasID]  SMALLINT NULL,
    CONSTRAINT [sLoadNC_fk] FOREIGN KEY ([WorkID]) REFERENCES [dbo].[sWork] ([WorkID]) ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([wk] ASC)
);

