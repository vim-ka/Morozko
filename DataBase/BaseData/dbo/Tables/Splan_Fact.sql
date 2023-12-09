CREATE TABLE [dbo].[Splan_Fact] (
    [sfid]        INT             IDENTITY (1, 1) NOT NULL,
    [smid]        INT             NULL,
    [startDate]   DATETIME        NULL,
    [Hitag]       INT             NULL,
    [dep_id]      INT             NULL,
    [sv_id]       INT             NULL,
    [ag_id]       INT             NULL,
    [b_id]        INT             NULL,
    [netFlag]     BIT             DEFAULT ((0)) NULL,
    [WeightLimit] DECIMAL (10, 3) NULL,
    [QtyLimit]    INT             NULL,
    [RubLimit]    INT             NULL,
    [WeightFact]  DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [QtyFact]     INT             DEFAULT ((0)) NULL,
    [RubFact]     INT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([sfid] ASC)
);

