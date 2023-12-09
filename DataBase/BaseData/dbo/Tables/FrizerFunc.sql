CREATE TABLE [dbo].[FrizerFunc] (
    [ffid]     INT          IDENTITY (1, 1) NOT NULL,
    [FuncName] VARCHAR (25) NULL,
    [Ngrp]     INT          NULL,
    CONSTRAINT [FrizerFunc_pk] PRIMARY KEY CLUSTERED ([ffid] ASC),
    UNIQUE NONCLUSTERED ([ffid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Категория для расчета оборота', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerFunc', @level2type = N'COLUMN', @level2name = N'Ngrp';

