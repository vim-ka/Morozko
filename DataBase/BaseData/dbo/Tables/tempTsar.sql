CREATE TABLE [dbo].[tempTsar] (
    [ID]        INT             IDENTITY (1, 1) NOT NULL,
    [DocDate]   DATETIME        NULL,
    [DocNumber] VARCHAR (100)   NULL,
    [hitag]     INT             NULL,
    [MassaFL]   DECIMAL (10, 5) NULL,
    [Flag]      TINYINT         NULL,
    CONSTRAINT [PK__tempTsar__3214EC27E5DABD4E] PRIMARY KEY CLUSTERED ([ID] ASC)
);

