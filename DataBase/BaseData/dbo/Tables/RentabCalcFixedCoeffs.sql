CREATE TABLE [dbo].[RentabCalcFixedCoeffs] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [type]    INT             NULL,
    [ym_from] INT             NULL,
    [ym_to]   INT             NULL,
    [val]     NUMERIC (12, 3) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

