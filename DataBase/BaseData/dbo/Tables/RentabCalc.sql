CREATE TABLE [dbo].[RentabCalc] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [ym_from]  INT             NULL,
    [ym_to]    INT             NULL,
    [calctip]  INT             NULL,
    [ncod]     INT             NULL,
    [ngrp]     INT             DEFAULT ((-1)) NULL,
    [postvol]  INT             NULL,
    [obl_id]   INT             NULL,
    [cost]     NUMERIC (12, 2) NULL,
    [price]    NUMERIC (12, 2) NULL,
    [calcvid]  INT             NULL,
    [nds]      NUMERIC (12, 2) CONSTRAINT [DF__RentabCalc__nds__5FAC4391] DEFAULT ((0)) NULL,
    [postvol2] INT             NULL,
    [hitag]    INT             DEFAULT ((-1)) NULL,
    [ncod_p]   INT             DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx6]
    ON [dbo].[RentabCalc]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx5]
    ON [dbo].[RentabCalc]([obl_id] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx4]
    ON [dbo].[RentabCalc]([ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx3]
    ON [dbo].[RentabCalc]([ym_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx2]
    ON [dbo].[RentabCalc]([ym_from] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalc_idx]
    ON [dbo].[RentabCalc]([ncod] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'факт или план', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabCalc', @level2type = N'COLUMN', @level2name = N'calcvid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'объем поставок/продаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabCalc', @level2type = N'COLUMN', @level2name = N'postvol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'типа расчета: продавец или покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabCalc', @level2type = N'COLUMN', @level2name = N'calctip';

