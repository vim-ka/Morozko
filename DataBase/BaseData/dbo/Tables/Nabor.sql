CREATE TABLE [dbo].[Nabor] (
    [NabID] INT           IDENTITY (1, 1) NOT NULL,
    [ND]    DATETIME      NULL,
    [Tm]    VARBINARY (8) NULL,
    [Marsh] INT           NULL,
    [Op]    SMALLINT      NULL,
    UNIQUE NONCLUSTERED ([NabID] ASC)
);

