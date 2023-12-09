CREATE TABLE [Guard].[DetailQuot] (
    [DqID]       INT             IDENTITY (1, 1) NOT NULL,
    [CoID]       INT             NOT NULL,
    [AG_ID]      INT             NULL,
    [B_ID]       INT             NULL,
    [Hitag]      INT             NULL,
    [PlanQty]    INT             NULL,
    [PlanWeight] DECIMAL (10, 1) NULL,
    PRIMARY KEY CLUSTERED ([DqID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ComDAdd1]
    ON [Guard].[DetailQuot]([CoID] ASC, [AG_ID] ASC, [B_ID] ASC, [Hitag] ASC);

