CREATE TABLE [dbo].[NV_BAD] (
    [nvId]        INT             IDENTITY (1, 1) NOT NULL,
    [DatNom]      INT             NULL,
    [TekID]       INT             NULL,
    [Hitag]       INT             NULL,
    [Price]       MONEY           NULL,
    [Cost]        MONEY           NULL,
    [Kol]         DECIMAL (10, 3) NOT NULL,
    [Kol_B]       DECIMAL (10, 3) NOT NULL,
    [Sklad]       TINYINT         NULL,
    [BasePrice]   MONEY           NULL,
    [Remark]      VARCHAR (80)    NULL,
    [tip]         TINYINT         NULL,
    [Meas]        TINYINT         NULL,
    [DelivCancel] BIT             NULL,
    [OrigPrice]   DECIMAL (10, 2) NULL,
    [ag_id]       INT             NULL
);

