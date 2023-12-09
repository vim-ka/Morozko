CREATE TABLE [dbo].[ParamNV] (
    [Comp]         VARCHAR (30)     NULL,
    [ID]           INT              NULL,
    [Hitag]        INT              NULL,
    [MinP]         INT              NULL,
    [Mpu]          INT              NULL,
    [Nds]          INT              NULL,
    [Cost]         DECIMAL (12, 5)  NULL,
    [Price]        DECIMAL (14, 4)  NULL,
    [OrigPrice]    DECIMAL (14, 4)  NULL,
    [Sklad]        INT              NULL,
    [Kol]          DECIMAL (12, 5)  NULL,
    [kol_b]        DECIMAL (12, 5)  NULL,
    [NewKol]       DECIMAL (12, 5)  NULL,
    [Country]      VARCHAR (30)     NULL,
    [DateR]        VARCHAR (8)      NULL,
    [SrokH]        VARCHAR (8)      NULL,
    [Sert_ID]      INT              NULL,
    [Name]         VARCHAR (100)    NULL,
    [Ngrp]         INT              NULL,
    [Gtd]          VARCHAR (25)     NULL,
    [Ispr0]        DECIMAL (10, 3)  NULL,
    [Ispr1]        DECIMAL (10, 3)  NULL,
    [NewLine]      BIT              NULL,
    [Ostat]        DECIMAL (12, 3)  NULL,
    [MatrPrice]    DECIMAL (10, 2)  DEFAULT ((0)) NULL,
    [Detach]       BIT              NULL,
    [OldPrice]     DECIMAL (14, 2)  NULL,
    [NvID]         INT              NULL,
    [minExtra]     DECIMAL (6, 3)   NULL,
    [PredZakaz]    BIT              NULL,
    [LMU]          BIT              NULL,
    [DCK]          INT              NULL,
    [minNacen]     DECIMAL (6, 2)   NULL,
    [EsfPrice]     DECIMAL (14, 4)  DEFAULT ((0)) NULL,
    [EsfKol]       DECIMAL (10, 3)  CONSTRAINT [DF__ParamNV__EsfKol__0063F73D] DEFAULT ((0)) NULL,
    [PLU]          VARCHAR (16)     NULL,
    [Done]         BIT              DEFAULT ((0)) NULL,
    [FixedPrice]   BIT              DEFAULT ((0)) NULL,
    [NmHitag]      INT              NULL,
    [PriceTip]     SMALLINT         NULL,
    [nmid]         INT              NULL,
    [LastPrice]    DECIMAL (15, 2)  NULL,
    [VitrPrice]    DECIMAL (12, 2)  DEFAULT ((0)) NULL,
    [SourCost]     DECIMAL (12, 5)  DEFAULT ((0)) NULL,
    [BackReasonID] INT              DEFAULT ((0)) NULL,
    [ReasonRemark] VARCHAR (100)    NULL,
    [flgNvZakaz]   BIT              DEFAULT ((0)) NULL,
    [NzID]         INT              DEFAULT ((0)) NULL,
    [Unid]         SMALLINT         NULL,
    [K]            DECIMAL (18, 10) DEFAULT ((1)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэффициент пересчета из базовой единицы в текущую. Например, при K=2 все цены следует поделить пополам, а все количества удвоить', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ParamNV', @level2type = N'COLUMN', @level2name = N'K';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущая единица измерения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ParamNV', @level2type = N'COLUMN', @level2name = N'Unid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на NvZakaz', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ParamNV', @level2type = N'COLUMN', @level2name = N'NzID';

