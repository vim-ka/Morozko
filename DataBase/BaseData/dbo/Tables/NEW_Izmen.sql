CREATE TABLE [dbo].[NEW_Izmen] (
    [izmID]       INT             IDENTITY (1, 1) NOT NULL,
    [Nomer]       SMALLINT        NULL,
    [ND]          DATETIME        CONSTRAINT [DF__Izmen__ND__18C32EAE_copy] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]          VARCHAR (8)     DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Act]         CHAR (4)        NULL,
    [ID]          INT             NULL,
    [NewID]       INT             NULL,
    [Kol]         DECIMAL (12, 3) NULL,
    [NewKol]      DECIMAL (12, 3) NULL,
    [Price]       MONEY           NULL,
    [NewPrice]    MONEY           NULL,
    [Cost]        MONEY           NULL,
    [NewCost]     MONEY           NULL,
    [Ncod]        INT             NULL,
    [Ncom]        INT             NOT NULL,
    [OP]          SMALLINT        NULL,
    [Remark]      VARCHAR (40)    NULL,
    [Mrk]         CHAR (1)        NULL,
    [Comp]        VARCHAR (16)    NULL,
    [Sklad]       SMALLINT        NULL,
    [NewSklad]    SMALLINT        NULL,
    [Printed]     BIT             NULL,
    [smi]         MONEY           NULL,
    [DCK]         INT             NULL,
    [SerialNom]   INT             DEFAULT ((0)) NULL,
    [wsid]        TINYINT         NULL,
    [newWsid]     TINYINT         NULL,
    [Hitag]       INT             NOT NULL,
    [irID]        INT             DEFAULT ((0)) NULL,
    [DivFlag]     BIT             DEFAULT ((0)) NULL,
    [NewHitag]    INT             NOT NULL,
    [Weight]      DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [NewWeight]   DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [ServiceFlag] BIT             DEFAULT ((0)) NULL,
    [pin]         INT             NOT NULL,
    [UnID]        SMALLINT        DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Izmen_pk_copy] PRIMARY KEY CLUSTERED ([izmID] ASC),
    CONSTRAINT [Izmen_ck_copy] CHECK ([DCK]<>(0))
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160902-132419]
    ON [dbo].[NEW_Izmen]([Act] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160902-130538]
    ON [dbo].[NEW_Izmen]([Act] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160902-130252]
    ON [dbo].[NEW_Izmen]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx7]
    ON [dbo].[NEW_Izmen]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx6]
    ON [dbo].[NEW_Izmen]([ID] ASC, [NewID] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx5]
    ON [dbo].[NEW_Izmen]([NewID] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx4]
    ON [dbo].[NEW_Izmen]([ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx3]
    ON [dbo].[NEW_Izmen]([SerialNom] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx2]
    ON [dbo].[NEW_Izmen]([ND] ASC, [ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Izmen_idx]
    ON [dbo].[NEW_Izmen]([izmID] ASC, [ND] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Новый код для операции Act=''Tran'' (трансмутация)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'NewHitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для опер. div+,div-: true-разбиение, false-слияние', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'DivFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для связи с таблицей оснований IzmenReason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'irID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tran - переделка товара в другой. Div+/Div- слияние-деление. ИзмЦ переоценка. Скла перемещение.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_Izmen', @level2type = N'COLUMN', @level2name = N'Act';

