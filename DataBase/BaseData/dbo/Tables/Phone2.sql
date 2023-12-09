CREATE TABLE [dbo].[Phone2] (
    [PhID]    INT          IDENTITY (1, 1) NOT NULL,
    [Number]  VARCHAR (20) NULL,
    [Tarif]   VARCHAR (15) NULL,
    [ND]      CHAR (15)    NULL,
    [Dogovor] VARCHAR (15) NULL,
    [Firma]   VARCHAR (25) NULL,
    [Status]  VARCHAR (15) NULL,
    [Region]  VARCHAR (10) NULL,
    UNIQUE NONCLUSTERED ([PhID] ASC),
    CONSTRAINT [Phone2_uq] UNIQUE NONCLUSTERED ([Number] ASC)
);

