CREATE TABLE [dbo].[AgAddDef_DEL] (
    [ag_id] INT      NULL,
    [pin]   INT      NULL,
    [ND]    DATETIME DEFAULT (getdate()) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AgAddDef_uq]
    ON [dbo].[AgAddDef_DEL]([ag_id] ASC, [pin] ASC);

