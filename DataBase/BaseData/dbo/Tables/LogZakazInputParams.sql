CREATE TABLE [dbo].[LogZakazInputParams] (
    [B_ID]        INT           NULL,
    [DCK]         INT           NULL,
    [CompName]    VARCHAR (30)  NULL,
    [Tip]         VARCHAR (40)  NULL,
    [Hitag]       INT           NULL,
    [Qty]         FLOAT (53)    NULL,
    [Price]       MONEY         NULL,
    [ClearZakaz]  BIT           NULL,
    [OP]          INT           NULL,
    [Ag_id]       INT           NULL,
    [Remark]      VARCHAR (255) NULL,
    [SavedZakaz]  FLOAT (53)    NULL,
    [Force_ag_id] INT           NULL,
    [StfNom]      VARCHAR (17)  NULL,
    [StfDate]     DATETIME      NULL,
    [DocNom]      VARCHAR (20)  NULL,
    [DocDate]     DATETIME      NULL,
    [Tm]          VARCHAR (10)  DEFAULT (CONVERT([varchar](10),getdate(),(108))) NULL,
    [ND]          VARCHAR (10)  DEFAULT (CONVERT([varchar](10),getdate(),(104))) NULL
);

