CREATE TABLE [dbo].[DOT_Cup] (
    [CupNom]    INT             IDENTITY (1, 1) NOT NULL,
    [Dot]       INT             NULL,
    [ND]        DATETIME        NULL,
    [LastNcom]  INT             DEFAULT ((0)) NULL,
    [CalcRest]  DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [FactGoods] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [FactKassa] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [OutKassa]  DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Rashod]    DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Ostat]     DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Dolg]      DECIMAL (12, 2) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([CupNom] ASC)
);

