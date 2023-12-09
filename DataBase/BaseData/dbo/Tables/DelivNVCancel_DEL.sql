CREATE TABLE [dbo].[DelivNVCancel_DEL] (
    [dnvID]   INT          IDENTITY (1, 1) NOT NULL,
    [DatNom]  INT          NOT NULL,
    [nvID]    INT          NOT NULL,
    [FCancel] BIT          NULL,
    [Remark]  VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([dnvID] ASC)
);

