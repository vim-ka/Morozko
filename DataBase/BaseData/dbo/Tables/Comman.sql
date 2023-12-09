CREATE TABLE [dbo].[Comman] (
    [Ncom]        INT             NOT NULL,
    [Ncod]        INT             NULL,
    [date]        DATETIME        NULL,
    [Time]        VARCHAR (8)     NULL,
    [summaprice]  DECIMAL (12, 2) NOT NULL,
    [summacost]   DECIMAL (12, 2) CONSTRAINT [DF__Comman__summacos__76818E95] DEFAULT ((0)) NOT NULL,
    [izmen]       DECIMAL (12, 2) CONSTRAINT [DF__Comman__izmen__7775B2CE] DEFAULT ((0)) NOT NULL,
    [isprav]      DECIMAL (12, 2) CONSTRAINT [DF__Comman__isprav__3B2BBE9D] DEFAULT ((0)) NOT NULL,
    [remove]      DECIMAL (12, 2) CONSTRAINT [DF__Comman__remove__795DFB40] DEFAULT ((0)) NOT NULL,
    [ostat]       DECIMAL (12, 2) CONSTRAINT [DF__Comman__ostat__3C1FE2D6] DEFAULT ((0)) NULL,
    [realiz]      DECIMAL (12, 2) CONSTRAINT [DF__Comman__realiz__3D14070F] DEFAULT ((0)) NULL,
    [corr]        DECIMAL (12, 2) CONSTRAINT [DF__Comman__corr__3A379A64] DEFAULT ((0)) NOT NULL,
    [plata]       DECIMAL (12, 2) CONSTRAINT [DF__Comman__plata__7869D707] DEFAULT ((0)) NOT NULL,
    [closdate]    DATETIME        NULL,
    [srok]        INT             NULL,
    [op]          SMALLINT        NULL,
    [our_id]      SMALLINT        NULL,
    [doc_nom]     VARCHAR (20)    NULL,
    [doc_date]    DATETIME        NULL,
    [comp]        VARCHAR (16)    NULL,
    [izmensc]     DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [errflag]     INT             NULL,
    [copyexists]  INT             NULL,
    [origdate]    DATETIME        NULL,
    [skman]       VARCHAR (30)    NULL,
    [grman]       VARCHAR (30)    NULL,
    [DCK]         INT             NOT NULL,
    [TN_nom]      VARCHAR (30)    NULL,
    [TN_date]     DATETIME        NULL,
    [OrdersID]    INT             NULL,
    [safeCust]    BIT             DEFAULT ((0)) NULL,
    [PrihodDate]  DATETIME        NULL,
    [PrihodOp]    INT             NULL,
    [PinOwner]    INT             DEFAULT ((0)) NULL,
    [DCKOwner]    INT             DEFAULT ((0)) NULL,
    [pin]         INT             NULL,
    [dlMarshID]   INT             DEFAULT ((0)) NOT NULL,
    [dlMarshCost] DECIMAL (12, 2) DEFAULT ((0)) NOT NULL,
    [PrihodRID]   INT             DEFAULT ((0)) NOT NULL,
    [OLD_Ncom]    INT             NULL,
    CONSTRAINT [Comman_pk] PRIMARY KEY CLUSTERED ([Ncom] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Comman_idx3]
    ON [dbo].[Comman]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [Comman_idx2]
    ON [dbo].[Comman]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [Comman_idx]
    ON [dbo].[Comman]([Ncod] ASC);


GO
CREATE TRIGGER dbo.trigRemove ON dbo.Comman
WITH EXECUTE AS CALLER
FOR UPDATE
AS
declare @m1 money
declare @m2 money
declare @Nc int
BEGIN
 set @m1=(select max(Remove) from Deleted);
 set @m2=(select max(Remove) from Inserted);
 set @Nc=(select max(Ncom) from Inserted);
  if @m1<>@m2
   insert into CommRem (StartRemove,EndRemove,NCOM) values (@m1,@m2,@Nc)
END
GO
DISABLE TRIGGER [dbo].[trigRemove]
    ON [dbo].[Comman];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика из DEF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор договора владельца', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'DCKOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор владельца прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'PinOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Опереатор(ветеренария) вводивший дату', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'PrihodOp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата изменение дат изготовления и сроков хранения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'PrihodDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ответ. хранение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'safeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД заявки Orders', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'OrdersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата тов накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'TN_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер тов накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'TN_nom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Грузчик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'grman';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кладовщик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'skman';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'компьютер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата счет фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'doc_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер счет фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'doc_nom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наша фирма', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'our_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'срок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата закрытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'closdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'summacost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'summaprice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Comman', @level2type = N'COLUMN', @level2name = N'Ncom';

