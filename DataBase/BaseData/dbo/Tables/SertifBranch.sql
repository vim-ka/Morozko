CREATE TABLE [dbo].[SertifBranch] (
    [BrNo]    INT            IDENTITY (1, 1) NOT NULL,
    [BrName]  VARCHAR (80)   NULL,
    [Obl_ID]  INT            DEFAULT ((0)) NULL,
    [Rn_ID]   INT            DEFAULT ((0)) NULL,
    [Address] VARCHAR (100)  NULL,
    [Phone]   VARCHAR (50)   NULL,
    [Contact] VARCHAR (40)   NULL,
    [PosX]    NUMERIC (9, 5) DEFAULT ((0)) NULL,
    [PosY]    NUMERIC (9, 5) DEFAULT ((0)) NULL,
    [woPay]   BIT            DEFAULT ((0)) NULL,
    [isDel]   BIT            DEFAULT ((0)) NOT NULL,
    [pin]     INT            DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([BrNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Без оплаты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifBranch', @level2type = N'COLUMN', @level2name = N'woPay';

