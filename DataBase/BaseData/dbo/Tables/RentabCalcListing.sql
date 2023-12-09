CREATE TABLE [dbo].[RentabCalcListing] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [ym_from]     INT             NULL,
    [ym_to]       INT             NULL,
    [calctip]     INT             NULL,
    [ncod]        INT             NULL,
    [ngrp]        INT             NULL,
    [obl_id]      INT             NULL,
    [l_sum_opl]   NUMERIC (12, 2) NULL,
    [l_sum_vozm]  NUMERIC (12, 2) NULL,
    [listtipoper] INT             DEFAULT ((1)) NULL,
    [code]        INT             DEFAULT ((-1)) NULL,
    [postvol]     NUMERIC (10, 3) DEFAULT ((0)) NULL,
    [sum_postvol] NUMERIC (10, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx6]
    ON [dbo].[RentabCalcListing]([obl_id] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx5]
    ON [dbo].[RentabCalcListing]([ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx4]
    ON [dbo].[RentabCalcListing]([ncod] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx3]
    ON [dbo].[RentabCalcListing]([calctip] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx2]
    ON [dbo].[RentabCalcListing]([ym_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcListing_idx]
    ON [dbo].[RentabCalcListing]([ym_from] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-оплата 2-возмещение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RentabCalcListing', @level2type = N'COLUMN', @level2name = N'listtipoper';

