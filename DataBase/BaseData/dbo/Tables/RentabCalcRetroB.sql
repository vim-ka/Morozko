CREATE TABLE [dbo].[RentabCalcRetroB] (
    [id]      INT             IDENTITY (1, 1) NOT NULL,
    [ym_from] INT             NULL,
    [ym_to]   INT             NULL,
    [obl_id]  INT             NULL,
    [plata]   NUMERIC (12, 2) NULL,
    [ncod]    INT             NULL,
    [ngrp]    INT             NULL,
    [hitag]   INT             DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [RentabCalcRetroB_idx5]
    ON [dbo].[RentabCalcRetroB]([ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcRetroB_idx4]
    ON [dbo].[RentabCalcRetroB]([ncod] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcRetroB_idx3]
    ON [dbo].[RentabCalcRetroB]([obl_id] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcRetroB_idx2]
    ON [dbo].[RentabCalcRetroB]([ym_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabCalcRetroB_idx]
    ON [dbo].[RentabCalcRetroB]([ym_from] ASC);

