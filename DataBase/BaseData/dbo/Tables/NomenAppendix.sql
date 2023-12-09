CREATE TABLE [dbo].[NomenAppendix] (
    [Lotag]     INT             IDENTITY (1, 1) NOT NULL,
    [Hitag]     INT             NULL,
    [Name]      VARCHAR (100)   NULL,
    [BasePrice] DECIMAL (10, 2) NULL,
    [Qty]       INT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Lotag] ASC)
);

