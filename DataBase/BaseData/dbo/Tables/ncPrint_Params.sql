CREATE TABLE [dbo].[ncPrint_Params] (
    [comp]       VARCHAR (30) NULL,
    [BackDatnom] BIGINT       NULL
);


GO
CREATE NONCLUSTERED INDEX [ncPrint_Params_idx2]
    ON [dbo].[ncPrint_Params]([BackDatnom] ASC);


GO
CREATE NONCLUSTERED INDEX [ncPrint_Params_idx]
    ON [dbo].[ncPrint_Params]([comp] ASC);

