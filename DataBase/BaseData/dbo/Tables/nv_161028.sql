CREATE TABLE [dbo].[nv_161028] (
    [datnom]   INT             NULL,
    [tekid]    INT             NULL,
    [oldprice] DECIMAL (12, 2) NULL,
    [newprice] DECIMAL (12, 2) NULL,
    [oldcost]  DECIMAL (15, 5) NULL,
    [newcost]  DECIMAL (15, 5) NULL,
    [nd]       DATETIME        DEFAULT (getdate()) NULL
);

