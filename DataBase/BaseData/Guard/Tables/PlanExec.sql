CREATE TABLE [Guard].[PlanExec] (
    [Comp]            VARCHAR (30)    CONSTRAINT [DF__PlanExec__Comp__2D6ADC87] DEFAULT ('') NULL,
    [dck]             INT             NULL,
    [b_id]            INT             NULL,
    [Plann]           BIT             NULL,
    [ag_id]           INT             NULL,
    [dt]              CHAR (5)        NULL,
    [BName]           VARCHAR (100)   NULL,
    [FactT]           CHAR (8)        NULL,
    [Tara]            INT             NULL,
    [Audit]           CHAR (8)        NULL,
    [AdvOrd]          CHAR (8)        NULL,
    [NeudSpr]         INT             NULL,
    [LastSver]        DATE            NULL,
    [LastSell]        DATE            NULL,
    [DayProd]         CHAR (20)       NULL,
    [Debt]            DECIMAL (12, 2) CONSTRAINT [DF__PlanExec__Debt__2A8E6FDC] DEFAULT ((0)) NULL,
    [Overdue]         DECIMAL (12, 2) CONSTRAINT [DF__PlanExec__Overdu__2B829415] DEFAULT ((0)) NULL,
    [Over17]          DECIMAL (12, 2) CONSTRAINT [DF__PlanExec__Over17__2C76B84E] DEFAULT ((0)) NULL,
    [Deep]            INT             NULL,
    [WeekSell]        DECIMAL (12, 2) NULL,
    [MonthSell]       DECIMAL (12, 2) NULL,
    [WeekPay]         DECIMAL (12, 2) NULL,
    [MonthPay]        DECIMAL (12, 2) NULL,
    [DepID]           INT             NULL,
    [sv_ag_id]        INT             NULL,
    [SuperFam]        VARCHAR (100)   NULL,
    [DayPay]          DECIMAL (10, 2) NULL,
    [FrizQty]         INT             NULL,
    [gpAddr]          VARCHAR (200)   NULL,
    [LastSverSVDate]  DATETIME        NULL,
    [LastSverSVState] INT             NULL,
    [Photos]          SMALLINT        DEFAULT ((0)) NULL,
    [AgentFam]        VARCHAR (100)   NULL,
    [TodaySell]       DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [SkipT]           VARCHAR (8)     NULL,
    [Tip]             SMALLINT        DEFAULT ((0)) NULL,
    [PlanLikvid]      DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [FactLikvid]      DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [FactBrak]        DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [PlanLikvidPcs]   INT             NULL,
    [FactLikvidPcs]   INT             NULL,
    [FactBrakPcs]     INT             NULL,
    [PlanBrak]        DECIMAL (10, 3) NULL,
    [PlanBrakPcs]     INT             NULL,
    [PlanLikvid38]    DECIMAL (10, 3) NULL,
    [PlanLikvid78]    DECIMAL (10, 3) NULL,
    [PlanLikvid85]    DECIMAL (10, 3) NULL,
    [PlanLikvid71]    DECIMAL (10, 3) NULL,
    [PlanLikvid38pcs] INT             NULL,
    [PlanLikvid78pcs] INT             NULL,
    [PlanLikvid85pcs] INT             NULL,
    [PlanLikvid71pcs] INT             NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время посещения, которое не будет показано в распечатке (это накладная, пробитая оператором, или перемещенная из предыдущего дня)', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'PlanExec', @level2type = N'COLUMN', @level2name = N'SkipT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время фактического посещения', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'PlanExec', @level2type = N'COLUMN', @level2name = N'FactT';

