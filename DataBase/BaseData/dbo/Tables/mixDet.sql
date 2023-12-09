CREATE TABLE [dbo].[mixDet] (
    [mdID]      INT             IDENTITY (1, 1) NOT NULL,
    [mxID]      SMALLINT        NOT NULL,
    [Hitag]     INT             NULL,
    [Qty]       DECIMAL (10, 3) NULL,
    [Koeff]     DECIMAL (10, 5) NULL,
    [Name]      VARCHAR (100)   NULL,
    [FlgWeight] BIT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([mdID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [mixDet_idx]
    ON [dbo].[mixDet]([Hitag] ASC);

