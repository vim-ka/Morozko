CREATE TABLE [dbo].[PrihodReqDet] (
    [PrihodRDetID]              INT             IDENTITY (1, 1) NOT NULL,
    [PrihodRID]                 INT             NULL,
    [PrihodRDetHitag]           INT             NULL,
    [PrihodRDetPrice]           FLOAT (53)      CONSTRAINT [DF__PrihodReq__Priho__01B6777B] DEFAULT ((0)) NULL,
    [PrihodRDetCost]            FLOAT (53)      CONSTRAINT [DF__PrihodReq__Priho__02AA9BB4] DEFAULT ((0)) NULL,
    [PrihodRDetTaraDSK]         INT             DEFAULT ((-1)) NULL,
    [PrihodRDetLocked]          BIT             DEFAULT ((0)) NULL,
    [PrihodRDetStorage]         INT             NULL,
    [PrihodRDetLevel]           INT             NULL,
    [PrihodRDetIndex]           INT             NULL,
    [PrihodRDetNLine]           INT             NULL,
    [PrihodRDetDepth]           INT             NULL,
    [PrihodRDetVolum]           DECIMAL (12, 2) NULL,
    [PrihodRDetGtd]             VARCHAR (100)   NULL,
    [PrihodRDetAddrID]          VARCHAR (1)     NULL,
    [PrihodRDetClone]           TINYINT         DEFAULT ((0)) NULL,
    [PrihodRDetCloneMain]       BIT             DEFAULT ((1)) NULL,
    [PrihodRDetSummaPrice]      DECIMAL (19, 4) DEFAULT ((0)) NULL,
    [PrihodRDetKolStr]          VARCHAR (10)    DEFAULT ((0)) NULL,
    [PrihodRDetSummaCost]       DECIMAL (19, 4) DEFAULT ((0)) NULL,
    [PrihodRDetOperatorID]      INT             NULL,
    [PrihodRDetDate]            DATETIME        NULL,
    [PrihodRDetSrokh]           DATETIME        NULL,
    [PrihodRDetSkladID]         INT             NULL,
    [PrihodRDetIsSave]          INT             CONSTRAINT [DF__PrihodReq__Priho__120B4427] DEFAULT ((0)) NULL,
    [PrihodRDetTara]            INT             NULL,
    [PrihodRDetCheck]           BIT             DEFAULT ((0)) NULL,
    [PrihodRDetNCom]            INT             NULL,
    [PrihodRDetKol]             FLOAT (53)      NULL,
    [PrihodRDetWeigth]          DECIMAL (12, 3) NULL,
    [PrihodRDetTaraVendID]      INT             NULL,
    [PrihodRDetShelfLife]       INT             DEFAULT ((0)) NULL,
    [PrihodRDetShelfLifeAdd]    INT             NULL,
    [PrihodRDetLockID]          INT             DEFAULT ((1)) NULL,
    [PrihodRDetAfterParty]      BIT             DEFAULT ((0)) NULL,
    [PrihodRDetMainCloneKolStr] VARCHAR (20)    CONSTRAINT [DF__PrihodReq__Priho__5B90CE93] DEFAULT ('0') NULL,
    [PrihodRDetMainCloneKol]    INT             DEFAULT ((0)) NULL,
    [PrihodRDetflg1kg]          SMALLINT        CONSTRAINT [DF__PrihodReq__Priho__16D18FF2] DEFAULT ((0)) NOT NULL,
    [sklad_done]                BIT             DEFAULT ((0)) NOT NULL,
    [sklad_group_id]            INT             DEFAULT ((-1)) NOT NULL,
    [shipping_mode]             INT             DEFAULT ((-1)) NOT NULL,
    [PrihodRDetKolStr_plan]     VARCHAR (10)    DEFAULT ((0)) NOT NULL,
    [QTY]                       DECIMAL (18, 4) DEFAULT ((0)) NOT NULL,
    [unID]                      INT             DEFAULT ((-1)) NOT NULL,
    [PrihodRNDS20]              DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([PrihodRDetID] ASC)
);


GO
CREATE TRIGGER dbo.PrihodReqDet_tru ON dbo.PrihodReqDet
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
	declare @id int
	declare @hitag int 
	declare @res smallint
	
	set @res=0
	
	select 	@id=PrihodRDetID,
					@hitag=PrihodRDetHitag
	from inserted
	
	if exists(select * from nomen where hitag=@hitag and flgWeight=0)
		set @res=0 
	else 
	begin
		if exists(select * 
							from inserted i 
							join deleted d on i.PrihodRDetID=d.PrihodRDetID
							where i.PrihodRDetCost=d.PrihodRDetCost 
										and i.PrihodRDetPrice=d.PrihodRDetPrice)
			set @res=0
		else 
			if exists(select * 
								from inserted i 
								join deleted d on i.PrihodRDetID=d.PrihodRDetID
								where i.PrihodRDetCost<>d.PrihodRDetCost)
				set @res=1
			else
				set @res=2		
	end
	
	update PrihodReqDet set PrihodRDetflg1kg=@res
	where PrihodRDetID=@id
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - товар штучный или цена продажи и цена прихода не изменились
1 - изменена цена прихода
2 - изменена цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetflg1kg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'первоначальное количество в главной строке клона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetMainCloneKolStr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дооприходование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetAfterParty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на справочник lock
4 - блокируется товар по сроку годности 
1 - разблокируется', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetLockID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на справочник примечаний PrihodDateAdd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetShelfLifeAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок годности в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetShelfLife';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'поставщик тары(потому что у нас еще есть поставщик Скажи и Скажи(тара)))', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetTaraVendID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetWeigth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количесвто', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetKol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид в comman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetNCom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'метка проверенности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetCheck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД Тары прицепленной ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetTara';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'были ли 1 - записаны строки ранее(дооприходование) 0 - не сохранены', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetIsSave';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид Склада', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetSkladID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'срок хранения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetSrokh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата изготоваления', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'в случае дооприходования запоминаем кто добавлял строки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetOperatorID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetSummaCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количество либо вес либо строкой вида 10+3 где 10 это коробки а 3 штуки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetKolStr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetSummaPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Главная строка в клоне', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetCloneMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ клона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetClone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адресное хранение - ключ к т.AddrSpace', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetAddrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер гтд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetGtd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetVolum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetDepth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ряд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetNLine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'полка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetIndex';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'этаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetLevel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'стеллаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetStorage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заблокировано или продажа только опт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetLocked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'договор с тарой', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetTaraDSK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetHitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид содержимого прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PrihodReqDet', @level2type = N'COLUMN', @level2name = N'PrihodRDetID';

