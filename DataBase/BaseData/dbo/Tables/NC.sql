CREATE TABLE [dbo].[NC] (
    [Ncid]         INT             IDENTITY (1, 1) NOT NULL,
    [DatNom]       BIGINT          NOT NULL,
    [ND]           DATETIME        NULL,
    [B_ID]         INT             NOT NULL,
    [B_ID2]        INT             NOT NULL,
    [Fam]          VARCHAR (35)    NULL,
    [TM]           CHAR (8)        NULL,
    [Op]           INT             NULL,
    [SP]           DECIMAL (12, 2) DEFAULT ((0)) NOT NULL,
    [SC]           DECIMAL (12, 2) DEFAULT ((0)) NOT NULL,
    [Extra]        DECIMAL (6, 2)  NULL,
    [Srok]         INT             DEFAULT ((0)) NOT NULL,
    [Fact]         DECIMAL (12, 2) CONSTRAINT [DF__NC_2_Fact__04DA9AE4_NC_2] DEFAULT ((0)) NULL,
    [OurID]        TINYINT         NULL,
    [Frizer]       TINYINT         CONSTRAINT [DF__NC_2_Frizer__4B0D20AB_NC_2] DEFAULT ((0)) NULL,
    [Ag_Id]        INT             NULL,
    [StfNom]       VARCHAR (17)    NULL,
    [StfDate]      DATETIME        NULL,
    [Remark]       VARCHAR (255)   NULL,
    [Printed]      TINYINT         CONSTRAINT [DF__NC_2_Printed__4C0144E4_NC_2] DEFAULT ((0)) NULL,
    [BoxQty]       DECIMAL (8, 2)  NULL,
    [Weight]       DECIMAL (8, 2)  NULL,
    [Actn]         TINYINT         DEFAULT ((0)) NULL,
    [CK]           TINYINT         NULL,
    [Tara]         TINYINT         DEFAULT ((0)) NULL,
    [RefDatnom]    BIGINT          CONSTRAINT [DF__NC_2_RefDatnom__4CF5691D_NC_2] DEFAULT ((0)) NOT NULL,
    [Izmen]        MONEY           DEFAULT ((0)) NULL,
    [Done]         BIT             CONSTRAINT [DF__NC_2_Done__03B16C81_NC_2] DEFAULT ((0)) NULL,
    [RemarkOp]     VARCHAR (50)    NULL,
    [Marsh2]       TINYINT         DEFAULT ((0)) NULL,
    [Ready]        BIT             NULL,
    [DelivCancel]  BIT             DEFAULT ((0)) NULL,
    [DayShift]     TINYINT         DEFAULT ((0)) NULL,
    [PrintedNak]   TINYINT         DEFAULT ((0)) NULL,
    [SertifDoc]    INT             DEFAULT ((0)) NULL,
    [TimeArrival]  CHAR (5)        CONSTRAINT [DF__NC__TimeArrival__0C91969C] DEFAULT ('00:00') NULL,
    [BruttoWeight] DECIMAL (12, 3) NULL,
    [TranspRashod] DECIMAL (10, 2) NULL,
    [Comp]         VARCHAR (30)    NULL,
    [DCK]          INT             NOT NULL,
    [NeedDover]    BIT             DEFAULT ((0)) NULL,
    [State]        TINYINT         DEFAULT ((0)) NULL,
    [DocNom]       VARCHAR (20)    NULL,
    [DocDate]      DATETIME        NULL,
    [SertNo]       VARCHAR (40)    NULL,
    [SertND]       DATETIME        NULL,
    [STip]         TINYINT         CONSTRAINT [DF__NC__STip__0F1A943A] DEFAULT ((0)) NULL,
    [gpOur_ID_old] TINYINT         CONSTRAINT [DF_NC_gpOur_ID] DEFAULT ((0)) NULL,
    [gpOur_ID]     INT             DEFAULT ((0)) NULL,
    [mhID]         INT             DEFAULT ((0)) NOT NULL,
    [DoverM2]      SMALLINT        DEFAULT ((0)) NULL,
    [StartDatnom]  BIGINT          NULL,
    [Nom]          VARCHAR (20)    NULL,
    [BSign]        TINYINT         DEFAULT ((0)) NULL,
    CONSTRAINT [NC_pk] PRIMARY KEY CLUSTERED ([DatNom] ASC),
    CONSTRAINT [NC_ck2] CHECK ([DCK]>(0)),
    CONSTRAINT [NC_uq] UNIQUE NONCLUSTERED ([Ncid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_mgid]
    ON [dbo].[NC]([mhID] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_2Bid_idx]
    ON [dbo].[NC]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_2ND_idx]
    ON [dbo].[NC]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_idx]
    ON [dbo].[NC]([RefDatnom] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_idx2]
    ON [dbo].[NC]([Frizer] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_idx3]
    ON [dbo].[NC]([Tara] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_idx4]
    ON [dbo].[NC]([Actn] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_idx5]
    ON [dbo].[NC]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [nc_strtidx]
    ON [dbo].[NC]([StartDatnom] ASC);


GO
CREATE TRIGGER trg_NC_i ON dbo.NC
WITH EXECUTE AS CALLER
FOR INSERT
AS
begin
  declare @gpOur_ID int 
  set @gpOur_ID=(select gpOur_ID from inserted)
  if isnull(@gpOur_ID,0)=0 
  insert into NCLOG (DatNom)
  select DatNom from inserted
end
GO
DISABLE TRIGGER [dbo].[trg_NC_i]
    ON [dbo].[NC];


GO
CREATE TRIGGER trg_NC_u ON dbo.NC
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into NCLOG (DatNom)
          select DatNom from inserted
      end
GO
DISABLE TRIGGER [dbo].[trg_NC_u]
    ON [dbo].[NC];


GO
 CREATE TRIGGER trg_NC_d ON dbo.NC
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into NCLOG (DatNom)
          select DatNom from deleted
      end
GO
DISABLE TRIGGER [dbo].[trg_NC_d]
    ON [dbo].[NC];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нумерация в пределах месяца', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Nom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Доверенность: 0-нет, 1-деньги, 2-товар.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DoverM2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Обновленный gpOur_ID, теперь типа int', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'gpOur_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сертификата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'SertND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер сертификата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'SertNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата входящего документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DocDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер входящего документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DocNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нужна доверенность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'NeedDover';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Рабочая станция, где создана накладная', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время прибытия на торговую точку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'TimeArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пакет документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'SertifDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сдвиг продажи в будущее', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DayShift';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доставка отменена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'DelivCancel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Очередность в маршруте', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Marsh2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ремарка оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'RemarkOp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма переоценки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Izmen';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DatNom исходной накладной (для возвратной)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'RefDatnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Накладная с тарой', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Tara';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Акция', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Actn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сколько раз распечатана', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Printed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата счет-фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'StfDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер счет-фактуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'StfNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Накладная с оборудованием', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Frizer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'OurID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма оплат по данной накладной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок консигнации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'Extra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вторая рука', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'B_ID2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC', @level2type = N'COLUMN', @level2name = N'B_ID';

