CREATE TABLE [dbo].[GRPrior] (
    [gpid]  INT      IDENTITY (1, 1) NOT NULL,
    [ngrp]  INT      NULL,
    [DepID] INT      NULL,
    [ND]    DATETIME CONSTRAINT [DF__GRPrior__ND__62A7151F] DEFAULT (getdate()) NULL,
    [OP]    INT      NULL,
    [Prior] CHAR (2) NULL,
    CONSTRAINT [PK__GRPrior__45BC6B541F57C32F] PRIMARY KEY CLUSTERED ([gpid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRPrior', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRPrior', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GRPrior', @level2type = N'COLUMN', @level2name = N'ngrp';

