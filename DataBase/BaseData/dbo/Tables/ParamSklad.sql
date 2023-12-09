CREATE TABLE [dbo].[ParamSklad] (
    [Comp]   VARCHAR (30)    NULL,
    [Act]    VARCHAR (4)     NULL,
    [Id]     INT             NULL,
    [Hitag]  INT             NULL,
    [Sklad]  INT             NULL,
    [Weight] DECIMAL (12, 3) NULL,
    [Price]  DECIMAL (12, 2) NULL,
    [Cost]   DECIMAL (15, 5) NULL,
    [Nomer]  INT             NOT NULL,
    [Qty]    INT             NOT NULL,
    [Ncom]   INT             DEFAULT ((0)) NULL,
    [NewID]  INT             NULL,
    [Ncod]   INT             DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx6]
    ON [dbo].[ParamSklad]([Ncom] ASC);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx5]
    ON [dbo].[ParamSklad]([Sklad] ASC);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx4]
    ON [dbo].[ParamSklad]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx3]
    ON [dbo].[ParamSklad]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx2]
    ON [dbo].[ParamSklad]([Act] ASC);


GO
CREATE NONCLUSTERED INDEX [ParamSklad_idx]
    ON [dbo].[ParamSklad]([Comp] ASC);

