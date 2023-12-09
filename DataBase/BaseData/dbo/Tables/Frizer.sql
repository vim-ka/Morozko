CREATE TABLE [dbo].[Frizer] (
    [Nom]            INT             IDENTITY (1, 1) NOT NULL,
    [Tip]            SMALLINT        CONSTRAINT [DF__Frizer__Tip__59063A47] DEFAULT ((0)) NULL,
    [Mode]           CHAR (1)        CONSTRAINT [DF__Frizer__Mode__59FA5E80] DEFAULT ('A') NULL,
    [InvNom]         VARCHAR (20)    NULL,
    [FabNom]         VARCHAR (15)    NULL,
    [Nname]          VARCHAR (60)    NULL,
    [Ncod]           INT             NULL,
    [DatePost]       DATETIME        NULL,
    [OurId]          TINYINT         CONSTRAINT [DF__Frizer__OurId__5AEE82B9] DEFAULT ((7)) NULL,
    [Ob]             FLOAT (53)      NULL,
    [Korzin]         SMALLINT        NULL,
    [Zamok]          TINYINT         CONSTRAINT [DF__Frizer__Zamok__5BE2A6F2] DEFAULT ((0)) NULL,
    [Sticker]        VARCHAR (3)     NULL,
    [B_ID]           INT             CONSTRAINT [DF__Frizer__B_ID__2043898E] DEFAULT ((0)) NOT NULL,
    [DateSell]       DATETIME        NULL,
    [Remark]         VARCHAR (20)    NULL,
    [DogNom]         VARCHAR (20)    CONSTRAINT [DF__Frizer__DogNom__4C4CF455] DEFAULT ('') NULL,
    [Price]          MONEY           NULL,
    [DateCheck]      DATETIME        NULL,
    [DateCheckAgent] DATETIME        NULL,
    [NCom]           INT             NULL,
    [SkladNo]        SMALLINT        CONSTRAINT [DF__Frizer__SkladNo__42397A36] DEFAULT ((0)) NULL,
    [Procreator]     VARCHAR (20)    NULL,
    [NCountry]       INT             NULL,
    [Cost]           DECIMAL (13, 5) NULL,
    [fsID]           SMALLINT        CONSTRAINT [DF__Frizer__fsID__4DE0370C] DEFAULT ((0)) NOT NULL,
    [mID]            SMALLINT        NULL,
    [CondID]         INT             NULL,
    [hitag]          INT             NULL,
    [StartPrice]     MONEY           CONSTRAINT [DF__Frizer__StartPri__0900FCDA] DEFAULT ((0)) NOT NULL,
    [DateStart]      DATETIME        DEFAULT ([dbo].[today]()) NOT NULL,
    [DateAct]        DATETIME        NULL,
    [InmarkoTip]     INT             NULL,
    [InvNom2]        VARCHAR (30)    NULL,
    [ffid]           INT             NULL,
    [DCK]            INT             CONSTRAINT [DF__Frizer__DCK__2D9E5003] DEFAULT ((0)) NULL,
    [length]         NUMERIC (7, 2)  DEFAULT ((0)) NULL,
    [high]           NUMERIC (7, 2)  NULL,
    [depth]          NUMERIC (7, 2)  DEFAULT ((0)) NULL,
    [FMod]           INT             DEFAULT ((0)) NOT NULL,
    [Weight]         DECIMAL (10, 2) DEFAULT ((500)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Nom] ASC),
    CONSTRAINT [Frizer_fk] FOREIGN KEY ([Tip]) REFERENCES [dbo].[FrizerTip] ([Tip]) ON UPDATE CASCADE,
    CONSTRAINT [Frizer_fk2] FOREIGN KEY ([fsID]) REFERENCES [dbo].[FrizerStick] ([fsID]) ON UPDATE CASCADE,
    CONSTRAINT [Frizer_fk3] FOREIGN KEY ([mID]) REFERENCES [dbo].[FrizerMode] ([mId]) ON UPDATE CASCADE,
    CONSTRAINT [Frizer_fk4] FOREIGN KEY ([CondID]) REFERENCES [dbo].[FrizerCond] ([CondID]) ON UPDATE CASCADE,
    CONSTRAINT [Frizer_fk5] FOREIGN KEY ([ffid]) REFERENCES [dbo].[FrizerFunc] ([ffid]) ON UPDATE CASCADE,
    CONSTRAINT [Frizer_fk7] FOREIGN KEY ([FMod]) REFERENCES [dbo].[FrizerModel] ([FMod]) ON UPDATE CASCADE
);


GO
CREATE TRIGGER [dbo].[Frizer_triu] ON [dbo].[Frizer]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
BEGIN
  declare @Nom int
  declare @OldNName varchar(60)
  declare @NewNName varchar(60)
  declare @OldInvNom varchar(20)
  declare @NewInvNom varchar(20)
  declare @OldNcod int
  declare @NewNcod int
 
  select @Nom = Nom,  @OldNName = NName, @OldInvNom = InvNom, @OldNCod=NCod from deleted
  select @NewNName = NName, @NewInvNom = InvNom, @NewNCod=NCod from inserted
  
  insert into FrizerLogDet (Nom,OldNName, NewNName, OldInvNom, NewInvNom, OldNcod, NewNcod)
              values (@Nom,@OldNName, @NewNName, @OldInvNom, @NewInvNom, @OldNcod, @NewNcod) 
END
GO
DISABLE TRIGGER [dbo].[Frizer_triu]
    ON [dbo].[Frizer];


GO
CREATE TRIGGER [dbo].[trg_Frizer_i] ON [dbo].[Frizer]
WITH EXECUTE AS CALLER
FOR INSERT
AS
      begin
          insert into FrizerNewLog (Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag, StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, [type])
          select Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag, StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, 0  from inserted
      end
GO
CREATE TRIGGER [dbo].[trg_Frizer_d] ON [dbo].[Frizer]
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into FrizerNewLog (Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag,  StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, [type])
          select Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag,  StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, 1 from deleted
      end
GO
CREATE TRIGGER [dbo].[trg_Frizer_u] ON [dbo].[Frizer]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into FrizerNewLog (Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag, StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, [type])
          select Nom, Tip, Mode, InvNom, FabNom, Nname, Ncod, DatePost, OurId, Ob, Korzin, Zamok, Sticker, B_ID, DateSell, Remark, DogNom, Price, DateCheck, DateCheckAgent, NCom, SkladNo, Procreator, NCountry, Cost, fsID, mID, CondID, hitag, StartPrice, DateStart, DateAct, InmarkoTip, InvNom2, ffid, DCK, 2 from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Модель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'FMod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'depth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Высота', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'high';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Длина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'length';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код основного договора по которому отгружено
оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FrizerFunc - назначение морозильных ларей', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'ffid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дополнительный инвентарный номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'InvNom2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип холодильника(справочник InmarkoTypeFrizer)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'InmarkoTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сдачи акта инвентаризации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DateAct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала эсплуатации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DateStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальная залоговая стоимость', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'StartPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код в Nomen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FrizerCond - состояние оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'CondID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FrizerMode - тип владения оборудованием', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'mID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FrizerStick - назначение морозильных ларей', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'fsID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код страны производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'NCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Производитель оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Procreator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'SkladNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ комиссии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'NCom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сверки агентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DateCheckAgent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сверки бухгалтером', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DateCheck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущая залоговая цена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ старого договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DogNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала последней аренды', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DateSell';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код клиента, 0 - на складе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'B_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Брэнд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Sticker';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во замков', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Zamok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во корзин', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Korzin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объём ларя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Ob';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код нашей фирмы из таблицы Firms', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'OurId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата оприходования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'DatePost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика из таблицы Vendors', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Nname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фабричный номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'FabNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Инвентарный номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'InvNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Аренда, лизинг и т.д.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Mode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип оборудования, ларь, корзина и т.д.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frizer', @level2type = N'COLUMN', @level2name = N'Tip';

