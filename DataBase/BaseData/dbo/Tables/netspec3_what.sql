CREATE TABLE [dbo].[netspec3_what] (
    [whid]          INT             IDENTITY (1, 1) NOT NULL,
    [nmid]          INT             NOT NULL,
    [Ncod]          INT             DEFAULT ((0)) NOT NULL,
    [Hitag]         INT             NOT NULL,
    [Cost]          DECIMAL (15, 5) NULL,
    [Price]         DECIMAL (14, 4) NULL,
    [isWeightPrice] BIT             DEFAULT ((0)) NULL,
    [ruID]          INT             NULL,
    PRIMARY KEY CLUSTERED ([whid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [netspec3_what_idx2]
    ON [dbo].[netspec3_what]([nmid] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec3_what_idx]
    ON [dbo].[netspec3_what]([Hitag] ASC);

