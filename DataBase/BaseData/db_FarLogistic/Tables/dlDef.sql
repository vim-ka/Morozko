CREATE TABLE [db_FarLogistic].[dlDef] (
    [ID]          INT           IDENTITY (200403, 1) NOT NULL,
    [brName]      VARCHAR (200) NULL,
    [brAddr]      VARCHAR (200) NULL,
    [dstAddr]     VARCHAR (200) NULL,
    [gpAddr]      VARCHAR (200) NULL,
    [OKPO]        VARCHAR (200) NULL,
    [brKpp]       VARCHAR (200) NULL,
    [brBank]      VARCHAR (200) NULL,
    [brBik]       VARCHAR (200) NULL,
    [brRs]        VARCHAR (200) NULL,
    [brCs]        VARCHAR (200) NULL,
    [Contact]     VARCHAR (200) NULL,
    [gpPhone]     VARCHAR (200) NULL,
    [Email]       VARCHAR (200) NULL,
    [isDel]       BIT           DEFAULT ((0)) NULL,
    [isVendor]    BIT           DEFAULT ((0)) NULL,
    [MorozDefPin] INT           NULL,
    [brINN]       VARCHAR (12)  NULL,
    [nal]         BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [dlDef_pk] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE TRIGGER db_FarLogistic.dlDef_tri ON db_FarLogistic.dlDef
WITH EXECUTE AS CALLER
INSTEAD OF INSERT
AS
declare @sync int
declare @id int
select @sync=i.MorozDefPin, @id=i.id from inserted i
if @sync<>-1
begin
	SET IDENTITY_INSERT db_FarLogistic.dlDef ON
	insert into db_FarLogistic.dlDef (
         db_FarLogistic.dlDef.ID,
         db_FarLogistic.dlDef.brAddr,
         db_FarLogistic.dlDef.brBank,
         db_FarLogistic.dlDef.brBik,
         db_FarLogistic.dlDef.brCs,
         db_FarLogistic.dlDef.brKpp,
         db_FarLogistic.dlDef.brName,
         db_FarLogistic.dlDef.brRs,
         db_FarLogistic.dlDef.Contact,
         db_FarLogistic.dlDef.dstAddr,
         db_FarLogistic.dlDef.Email,
         db_FarLogistic.dlDef.gpAddr,
         db_FarLogistic.dlDef.gpPhone,
         db_FarLogistic.dlDef.OKPO,
         db_FarLogistic.dlDef.MorozDefPin,
         db_FarLogistic.dlDef.brINN)
  select d.pin, d.brAddr, d.brBank, d.brBik, d.brCs, d.brKpp, d.brName, d.brRs, d.Contact, d.dstAddr, d.Email, d.gpAddr, d.gpPhone, d.OKPO, d.pin, d.brinn from def d
  where d.pin=@sync
  SET IDENTITY_INSERT db_FarLogistic.dlDef OFF
end
else
begin
	insert into db_FarLogistic.dlDef (
         db_FarLogistic.dlDef.brAddr,
         db_FarLogistic.dlDef.brBank,
         db_FarLogistic.dlDef.brBik,
         db_FarLogistic.dlDef.brCs,
         db_FarLogistic.dlDef.brKpp,
         db_FarLogistic.dlDef.brName,
         db_FarLogistic.dlDef.brRs,
         db_FarLogistic.dlDef.Contact,
         db_FarLogistic.dlDef.dstAddr,
         db_FarLogistic.dlDef.Email,
         db_FarLogistic.dlDef.gpAddr,
         db_FarLogistic.dlDef.gpPhone,
         db_FarLogistic.dlDef.OKPO,
         db_FarLogistic.dlDef.MorozDefPin,
         db_FarLogistic.dlDef.brinn,
         db_FarLogistic.dlDef.isVendor)
  select i.brAddr,
         i.brBank,
         i.brBik,
         i.brCs,
         i.brKpp,
         i.brName,
         i.brRs,
         i.Contact,
         i.dstAddr,
         i.Email,
         i.gpAddr,
         i.gpPhone,
         i.OKPO,
         -1,
         i.brinn,
         1 
  from inserted i
end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оплата наличными', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'nal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'синхронизация с мороз', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'MorozDefPin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'поставщик 1 плательщик 0', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'isVendor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'удален', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'isDel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование контрагента', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'brName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор плательщика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временная таблица плательщиков', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDef';

