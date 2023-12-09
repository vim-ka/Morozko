CREATE TABLE [dbo].[PromoReqStatus] (
    [stid]   INT          NULL,
    [stname] VARCHAR (50) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'статус заявки на промо акцию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoReqStatus';

