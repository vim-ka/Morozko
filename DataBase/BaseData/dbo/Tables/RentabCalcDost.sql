CREATE TABLE [dbo].[RentabCalcDost] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [ym_from] INT             NULL,
    [ym_to]   INT             NULL,
    [obl_id]  INT             NULL,
    [koeff]   NUMERIC (12, 2) NULL,
    [tip]     TINYINT         DEFAULT ((1)) NULL,
    [ngrp]    INT             NULL,
    [ncod]    INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx6]
    ON [dbo].[RentabCalcDost]([ncod] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx5]
    ON [dbo].[RentabCalcDost]([ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx4]
    ON [dbo].[RentabCalcDost]([tip] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx3]
    ON [dbo].[RentabCalcDost]([obl_id] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx2]
    ON [dbo].[RentabCalcDost]([ym_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDost_idx]
    ON [dbo].[RentabCalcDost]([ym_from] ASC);

