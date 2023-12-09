CREATE TABLE [Guard].[OverDet] (
    [DepId]        INT             NULL,
    [DName]        VARCHAR (70)    NULL,
    [sv_ag_id]     INT             NULL,
    [svFam]        VARCHAR (100)   NULL,
    [b_id]         INT             NULL,
    [dck]          INT             NULL,
    [gpname]       VARCHAR (255)   NULL,
    [TekOver]      DECIMAL (10, 2) NULL,
    [Deep]         INT             NULL,
    [LastWeekOver] DECIMAL (10, 2) NULL,
    [remark]       VARCHAR (40)    NULL,
    [Plata]        DECIMAL (10, 2) NULL,
    [Mess]         VARCHAR (50)    NULL,
    [IncomePlan]   DECIMAL (10, 2) NULL,
    [FrizQty]      INT             NULL,
    [LastDay]      VARCHAR (12)    NULL,
    [LastPay]      DECIMAL (10, 2) NULL,
    [BuhRemark]    VARCHAR (20)    NULL
);

