CREATE TABLE [Guard].[AutoOrder] (
    [AoID]       INT             IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME        NULL,
    [CreateDate] DATETIME        DEFAULT ([dbo].[today]()) NULL,
    [ag_id]      INT             NULL,
    [b_id]       INT             NULL,
    [Hitag]      INT             NULL,
    [flgWeight]  BIT             DEFAULT ((0)) NULL,
    [Qty]        DECIMAL (10, 3) NULL,
    [Comp]       VARCHAR (30)    DEFAULT (host_name()) NULL,
    [Done]       BIT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([AoID] ASC)
);

