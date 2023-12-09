CREATE TABLE [dbo].[RentabTarifDl] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [mainparent] INT            NULL,
    [grpname]    VARCHAR (512)  NULL,
    [tarif]      NUMERIC (7, 3) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

