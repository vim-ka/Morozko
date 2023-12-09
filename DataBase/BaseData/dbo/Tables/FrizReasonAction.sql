CREATE TABLE [dbo].[FrizReasonAction] (
    [fraId]   INT          NULL,
    [fraName] VARCHAR (20) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'причина совершения действия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizReasonAction';

