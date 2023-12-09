CREATE TABLE [dbo].[RentabCoeffs] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [year_month] INT             NULL,
    [hitag]      INT             NULL,
    [type]       INT             NULL,
    [val]        NUMERIC (10, 3) NULL,
    [ncod]       INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

