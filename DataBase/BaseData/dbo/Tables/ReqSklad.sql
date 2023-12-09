CREATE TABLE [dbo].[ReqSklad] (
    [Comp]  VARCHAR (16) NULL,
    [Sklad] INT          NULL
);


GO
CREATE CLUSTERED INDEX [ReqSklad_idx]
    ON [dbo].[ReqSklad]([Comp] ASC, [Sklad] ASC);

