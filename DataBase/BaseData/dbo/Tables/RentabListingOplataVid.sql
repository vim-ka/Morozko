CREATE TABLE [dbo].[RentabListingOplataVid] (
    [id]    INT             IDENTITY (1, 1) NOT NULL,
    [vid]   INT             NULL,
    [name]  VARCHAR (255)   NULL,
    [coeff] NUMERIC (12, 3) DEFAULT ((1)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'vid = 1 - оплата
vid = 2 - возмещение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabListingOplataVid', @level2type = N'COLUMN', @level2name = N'vid';

