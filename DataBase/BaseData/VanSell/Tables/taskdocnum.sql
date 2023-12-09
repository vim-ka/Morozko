CREATE TABLE [VanSell].[taskdocnum] (
    [id]     INT          NULL,
    [taskid] INT          NULL,
    [pin]    INT          NULL,
    [docnum] VARCHAR (15) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номера выданных накладных', @level0type = N'SCHEMA', @level0name = N'VanSell', @level1type = N'TABLE', @level1name = N'taskdocnum';

