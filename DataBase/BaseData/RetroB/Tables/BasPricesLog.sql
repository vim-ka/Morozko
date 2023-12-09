CREATE TABLE [RetroB].[BasPricesLog] (
    [prid]           INT             NOT NULL,
    [BPMid]          INT             NOT NULL,
    [Hitag]          INT             NOT NULL,
    [BaseCost]       DECIMAL (15, 5) NULL,
    [FinalCost]      DECIMAL (15, 5) NULL,
    [Day0]           DATETIME        NULL,
    [Day1]           DATETIME        NULL,
    [flgWeight]      BIT             NULL,
    [tip]            INT             NULL,
    [user_app_name]  VARCHAR (128)   DEFAULT (app_name()) NULL,
    [user_host_name] VARCHAR (128)   DEFAULT (host_name()) NULL,
    [user_nd]        DATETIME        DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - INS
1 - UPD
2 - DEL', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasPricesLog', @level2type = N'COLUMN', @level2name = N'tip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена за 1 кг', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasPricesLog', @level2type = N'COLUMN', @level2name = N'flgWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Окончательная цена прихода', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasPricesLog', @level2type = N'COLUMN', @level2name = N'FinalCost';

