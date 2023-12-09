CREATE TABLE [dbo].[NabDet] (
    [NID]     INT             IDENTITY (1, 1) NOT NULL,
    [NabID]   INT             NULL,
    [ND]      INT             NULL,
    [Tm]      VARCHAR (8)     NULL,
    [Hitag]   INT             NULL,
    [ID]      INT             NULL,
    [Kol]     NUMERIC (12, 4) NULL,
    [KolFact] NUMERIC (12, 4) NULL,
    [Op]      SMALLINT        NULL,
    [SkladNo] SMALLINT        NULL,
    UNIQUE NONCLUSTERED ([NID] ASC)
);

