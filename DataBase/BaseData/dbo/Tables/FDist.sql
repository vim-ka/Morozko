CREATE TABLE [dbo].[FDist] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [PlanND] DATETIME        NULL,
    [Dist]   NUMERIC (10, 2) NULL,
    [p_id]   INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FDist_idx3]
    ON [dbo].[FDist]([PlanND] ASC);


GO
CREATE NONCLUSTERED INDEX [FDist_idx]
    ON [dbo].[FDist]([p_id] ASC);


GO
CREATE CLUSTERED INDEX [FDist_idx4]
    ON [dbo].[FDist]([p_id] ASC);

