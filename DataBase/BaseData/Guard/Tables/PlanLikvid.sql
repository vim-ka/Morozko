CREATE TABLE [Guard].[PlanLikvid] (
    [ND]      DATETIME        NULL,
    [AG_ID]   INT             NULL,
    [dck]     INT             NULL,
    [Hitag]   INT             NULL,
    [Weight]  DECIMAL (10, 3) NULL,
    [RLikvid] DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [RBrak]   DECIMAL (10, 3) DEFAULT ((0)) NULL
);

