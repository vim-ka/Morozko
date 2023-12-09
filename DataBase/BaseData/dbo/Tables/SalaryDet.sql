CREATE TABLE [dbo].[SalaryDet] (
    [SalDet_ID]    INT             IDENTITY (1, 1) NOT NULL,
    [yy]           INT             NULL,
    [mm]           INT             NULL,
    [Level]        TINYINT         NULL,
    [ID]           INT             NULL,
    [DName]        VARCHAR (100)   NULL,
    [Sell]         DECIMAL (12, 2) NULL,
    [Plata]        DECIMAL (12, 2) NULL,
    [AutoKopl]     DECIMAL (12, 2) NULL,
    [Dohod]        DECIMAL (12, 2) NULL,
    [Dohod02]      DECIMAL (12, 2) NULL,
    [Bonus]        DECIMAL (12, 2) NULL,
    [BonusDeb]     DECIMAL (12, 2) NULL,
    [AvgDebt]      DECIMAL (12, 2) NULL,
    [AvgOverdue]   DECIMAL (12, 2) NULL,
    [AvgOverPerc]  DECIMAL (12, 2) NULL,
    [AvgBonus]     DECIMAL (12, 2) NULL,
    [LastDebt]     DECIMAL (12, 2) NULL,
    [LastOverdue]  DECIMAL (12, 2) NULL,
    [LastOverPerc] DECIMAL (12, 2) NULL,
    [LastBonus]    DECIMAL (12, 2) NULL,
    [Transport]    DECIMAL (12, 2) NULL,
    [Enabled]      BIT             NULL,
    [Editable]     BIT             NULL,
    [ImageIndex]   TINYINT         NULL,
    [Fg]           INT             NULL,
    [Bg]           INT             NULL,
    [Casket]       DECIMAL (10, 2) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([SalDet_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ларец', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SalaryDet', @level2type = N'COLUMN', @level2name = N'Casket';

