CREATE TABLE [dbo].[PrintOptions2] (
    [poid]      INT          IDENTITY (1, 1) NOT NULL,
    [ContrCode] INT          NULL,
    [ContrType] TINYINT      NULL,
    [PDType]    INT          NULL,
    [PDOptions] TINYINT      DEFAULT ((0)) NULL,
    [PrintQty]  TINYINT      NULL,
    [ND]        DATETIME     NULL,
    [TM]        CHAR (8)     NULL,
    [OP]        INT          NULL,
    [CompName]  VARCHAR (70) NULL,
    UNIQUE NONCLUSTERED ([poid] ASC)
);

