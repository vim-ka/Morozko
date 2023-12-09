CREATE TABLE [dbo].[FReqOtdelDet] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [reqnum] INT             NULL,
    [p_id]   INT             NULL,
    [summa]  NUMERIC (10, 2) NULL,
    CONSTRAINT [FReqOtdelDet_fk] FOREIGN KEY ([reqnum]) REFERENCES [dbo].[FReqOtdel] ([reqnum]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'удержание по сотрудникам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FReqOtdelDet';

