CREATE TABLE [dbo].[NEW_tdIZ] (
    [nd]          DATETIME        DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]          CHAR (8)        DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Act]         CHAR (4)        NULL,
    [ID]          INT             NULL,
    [NewId]       INT             NULL,
    [Kol]         DECIMAL (12, 3) NULL,
    [NewKol]      DECIMAL (12, 3) NULL,
    [Price]       MONEY           NULL,
    [NewPrice]    MONEY           NULL,
    [Cost]        MONEY           NULL,
    [NewCost]     MONEY           NULL,
    [Ncod]        INT             NULL,
    [Ncom]        INT             NULL,
    [Op]          INT             NULL,
    [Sklad]       SMALLINT        NULL,
    [NewSklad]    SMALLINT        NULL,
    [Remark]      VARCHAR (40)    NULL,
    [Printed]     BIT             DEFAULT ((0)) NULL,
    [Comp]        VARCHAR (16)    NULL,
    [SerialNom]   INT             DEFAULT ((0)) NULL,
    [DCK]         INT             NULL,
    [wsid]        TINYINT         NULL,
    [newWsid]     TINYINT         NULL,
    [Hitag]       INT             NULL,
    [irID]        INT             DEFAULT ((0)) NULL,
    [DivFlag]     BIT             NULL,
    [NewHitag]    INT             NULL,
    [Weight]      DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [NewWeight]   DECIMAL (12, 3) DEFAULT ((0)) NULL,
    [ServiceFlag] BIT             DEFAULT ((0)) NULL,
    [UnID]        SMALLINT        DEFAULT ((0)) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для опер. div+,div-: true-разбиение, false-слияние', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdIZ', @level2type = N'COLUMN', @level2name = N'DivFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Связь с IzmenReason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdIZ', @level2type = N'COLUMN', @level2name = N'irID';

