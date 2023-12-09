CREATE TABLE [dbo].[FCardsTip] (
    [fct]     INT          IDENTITY (1, 1) NOT NULL,
    [CardTip] VARCHAR (25) NULL,
    UNIQUE NONCLUSTERED ([fct] ASC)
);

