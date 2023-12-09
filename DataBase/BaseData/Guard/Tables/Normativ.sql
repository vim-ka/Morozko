CREATE TABLE [Guard].[Normativ] (
    [pin]     INT NULL,
    [hitag]   INT NULL,
    [MinRest] INT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Normativ_uq]
    ON [Guard].[Normativ]([pin] ASC, [hitag] ASC);

