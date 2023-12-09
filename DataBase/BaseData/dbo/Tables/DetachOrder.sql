CREATE TABLE [dbo].[DetachOrder] (
    [DID]    INT      IDENTITY (1, 1) NOT NULL,
    [DatNom] INT      NULL,
    [Sklad]  SMALLINT NULL,
    [Done]   BIT      NULL,
    UNIQUE NONCLUSTERED ([DID] ASC)
);

