CREATE TABLE [FinPlan].[fpPlat] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [plat_num] INT             NULL,
    [rs_code]  INT             NULL,
    [nd]       DATETIME        NULL,
    [pin]      INT             NULL,
    [plat_sum] NUMERIC (12, 2) NULL,
    [our_id]   INT             NULL,
    [comment]  VARCHAR (512)   NULL,
    [vid]      INT             NULL,
    [other]    BIT             DEFAULT ((0)) NULL,
    [isp]      BIT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'признак исполнения', @level0type = N'SCHEMA', @level0name = N'FinPlan', @level1type = N'TABLE', @level1name = N'fpPlat', @level2type = N'COLUMN', @level2name = N'isp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'если с минусом, то оплата, если с плюсом то поступление', @level0type = N'SCHEMA', @level0name = N'FinPlan', @level1type = N'TABLE', @level1name = N'fpPlat', @level2type = N'COLUMN', @level2name = N'vid';

