CREATE TABLE [dbo].[NC_ShippingType] (
    [STip]    TINYINT      NOT NULL,
    [Meaning] VARCHAR (40) NULL,
    [Actn]    BIT          CONSTRAINT [DF__ShippingTy__Actn__0E267001] DEFAULT ((0)) NULL,
    [Tara]    BIT          DEFAULT ((0)) NULL,
    CONSTRAINT [NC_ShippingType_uq] UNIQUE NONCLUSTERED ([STip] ASC)
);

