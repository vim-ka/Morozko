CREATE TABLE [dbo].[InmarkoFrizer] (
    [InmCode]    NUMERIC (15)  NOT NULL,
    [Type]       VARCHAR (30)  NULL,
    [Name]       VARCHAR (100) NULL,
    [VendInvNom] VARCHAR (15)  NULL,
    [InvNom]     VARCHAR (40)  NULL,
    [FabNom]     VARCHAR (25)  NULL,
    UNIQUE NONCLUSTERED ([InmCode] ASC)
);

