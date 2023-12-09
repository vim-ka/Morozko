CREATE TABLE [dbo].[FFuel] (
    [ffID]    INT             IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME        NULL,
    [Tm]      VARCHAR (8)     NULL,
    [OP]      INT             NULL,
    [uin]     INT             NULL,
    [PlanND]  DATETIME        NULL,
    [Vol]     NUMERIC (8, 2)  DEFAULT ((0)) NULL,
    [Dist]    NUMERIC (10, 2) NULL,
    [fueltip] INT             NULL,
    [fcID]    INT             NULL,
    [p_id]    INT             NULL,
    [locked]  BIT             DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([ffID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FFuel_idx3]
    ON [dbo].[FFuel]([PlanND] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuel_idx2]
    ON [dbo].[FFuel]([uin] ASC);


GO
CREATE NONCLUSTERED INDEX [FFuel_idx]
    ON [dbo].[FFuel]([p_id] ASC);


GO
CREATE CLUSTERED INDEX [FFuel_idx4]
    ON [dbo].[FFuel]([p_id] ASC);

