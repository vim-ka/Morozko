CREATE TABLE [dbo].[BankList] (
    [BnK]     INT           IDENTITY (1, 1) NOT NULL,
    [BName]   VARCHAR (80)  NULL,
    [Address] VARCHAR (50)  NULL,
    [BIK]     VARCHAR (15)  NULL,
    [CShet]   VARCHAR (254) NULL,
    [INN]     VARCHAR (10)  NULL,
    [City]    VARCHAR (50)  NULL,
    [OKPO]    VARCHAR (15)  NULL,
    [OGRN]    VARCHAR (15)  NULL,
    [KPP]     VARCHAR (12)  NULL,
    CONSTRAINT [UQ__BankList__C6D1394FBF4F93EF] UNIQUE NONCLUSTERED ([BnK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BankList_uq]
    ON [dbo].[BankList]([BIK] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Город', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankList', @level2type = N'COLUMN', @level2name = N'City';

