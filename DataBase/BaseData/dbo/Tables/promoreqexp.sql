CREATE TABLE [dbo].[promoreqexp] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [planexp] NUMERIC (10, 2) NULL,
    [factexp] NUMERIC (10, 2) NULL,
    [reqid]   INT             NULL,
    [expid]   INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

