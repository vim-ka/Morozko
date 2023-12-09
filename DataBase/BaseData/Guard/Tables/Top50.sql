CREATE TABLE [Guard].[Top50] (
    [hitag] INT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [UK_Top50_hitag]
    ON [Guard].[Top50]([hitag] ASC);

