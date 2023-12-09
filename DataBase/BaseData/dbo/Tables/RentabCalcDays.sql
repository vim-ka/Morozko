CREATE TABLE [dbo].[RentabCalcDays] (
    [id]      INT IDENTITY (1, 1) NOT NULL,
    [ym_from] INT NULL,
    [ym_to]   INT NULL,
    [obl_id]  INT NULL,
    [days]    INT NULL,
    [ncod]    INT NULL,
    [ngrp]    INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDays_idx5]
    ON [dbo].[RentabCalcDays]([ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDays_idx4]
    ON [dbo].[RentabCalcDays]([ncod] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDays_idx3]
    ON [dbo].[RentabCalcDays]([obl_id] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDays_idx2]
    ON [dbo].[RentabCalcDays]([ym_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcDays_idx]
    ON [dbo].[RentabCalcDays]([ym_from] ASC);

