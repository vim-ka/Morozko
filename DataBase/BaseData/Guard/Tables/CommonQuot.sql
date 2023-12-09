CREATE TABLE [Guard].[CommonQuot] (
    [CoID]       INT             IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME        NULL,
    [DepID]      SMALLINT        NULL,
    [Hitag]      INT             NULL,
    [PlanQty]    INT             NULL,
    [PlanWeight] DECIMAL (10, 1) NULL,
    PRIMARY KEY CLUSTERED ([CoID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ComQAdd2]
    ON [Guard].[CommonQuot]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [ComQAdd1]
    ON [Guard].[CommonQuot]([ND] ASC, [DepID] ASC);

