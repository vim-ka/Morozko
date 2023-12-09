CREATE TABLE [dbo].[GR] (
    [Ngrp]         INT          NOT NULL,
    [GrpName]      VARCHAR (50) NULL,
    [Vet]          BIT          DEFAULT (0) NULL,
    [Parent]       INT          DEFAULT ((0)) NOT NULL,
    [Category]     INT          CONSTRAINT [DF__GR__Category__68FD7645] DEFAULT ((1)) NULL,
    [MainParent]   INT          DEFAULT ((0)) NULL,
    [Levl]         INT          DEFAULT ((0)) NULL,
    [Prior]        CHAR (2)     NULL,
    [Cost1kgStor]  MONEY        NULL,
    [Cost1kgDeliv] MONEY        NULL,
    [nlMt]         INT          NULL,
    [AgInvis]      BIT          DEFAULT ((0)) NULL,
    [IsDel]        BIT          DEFAULT ((0)) NOT NULL,
    [OP]           INT          NOT NULL,
    [nlmt_new]     INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [GR_pk] PRIMARY KEY CLUSTERED ([Ngrp] ASC)
);


GO
CREATE NONCLUSTERED INDEX [GR_idx2]
    ON [dbo].[GR]([MainParent] ASC);


GO
CREATE NONCLUSTERED INDEX [GR_idx]
    ON [dbo].[GR]([Ngrp] ASC);


GO
CREATE NONCLUSTERED INDEX [MainGR_idx]
    ON [dbo].[GR]([MainParent] ASC);


GO
CREATE TRIGGER dbo.GR_tru ON dbo.GR
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  insert into GRLog(Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,
										Cost1kgStor,Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,ActTypeLog) 
	select 	Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,Cost1kgStor,
					Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,2
	from deleted
END
GO
CREATE TRIGGER dbo.GR_tri ON dbo.GR
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  insert into GRLog(Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,
										Cost1kgStor,Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,ActTypeLog) 
	select 	Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,Cost1kgStor,
					Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,1
	from inserted
END
GO
CREATE TRIGGER dbo.GR_trd ON dbo.GR
WITH EXECUTE AS CALLER
FOR DELETE
AS
BEGIN
  insert into GRLog(Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,
										Cost1kgStor,Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,ActTypeLog) 
	select 	Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,Prior,Cost1kgStor,
					Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,3
	from deleted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'последний пользователь', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'удалено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'IsDel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скрыта от агентов ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'AgInvis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на [NearLogistic] nlMassType (Расчет массы в рейсе)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'nlMt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость доставки 1 кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'Cost1kgDeliv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость хранения 1 кг сутки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'Cost1kgStor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'уровень вложенности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'Levl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Старший предок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GR', @level2type = N'COLUMN', @level2name = N'MainParent';

