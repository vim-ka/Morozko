﻿CREATE TABLE [Guard].[DepMatrixComplete] (
    [SV_ID]      INT             NULL,
    [SuperFam]   VARCHAR (100)   NULL,
    [ag_id]      INT             NULL,
    [ag_Fam]     VARCHAR (50)    NULL,
    [pin]        INT             NULL,
    [gpname]     VARCHAR (255)   NULL,
    [tmPlan]     VARCHAR (5)     NULL,
    [Tip]        SMALLINT        NULL,
    [tbAgSell]   VARCHAR (5)     NULL,
    [tmPhoto]    VARCHAR (5)     NULL,
    [tmRest]     VARCHAR (5)     NULL,
    [tmPay]      VARCHAR (5)     NULL,
    [tmopSell]   VARCHAR (5)     NULL,
    [NeedW1]     BIT             NULL,
    [NeedW2]     BIT             NULL,
    [NeedW3]     BIT             NULL,
    [NeedW4]     BIT             NULL,
    [NeedW5]     BIT             NULL,
    [NeedW6]     BIT             NULL,
    [NeedW7]     BIT             NULL,
    [Comment]    VARCHAR (40)    NULL,
    [ChainAg_ID] INT             NULL,
    [ChainFam]   VARCHAR (10)    NULL,
    [MLID]       INT             NULL,
    [StrTip]     VARCHAR (5)     NULL,
    [Comp]       VARCHAR (30)    NULL,
    [ForSale]    DECIMAL (10, 3) DEFAULT ((0)) NOT NULL,
    [FactSale]   DECIMAL (10, 3) DEFAULT ((0)) NOT NULL,
    [MinQty]     INT             DEFAULT ((0)) NULL
);

