CREATE TABLE [dbo].[IceOrders] (
    [ND]      DATETIME NULL,
    [nnak]    INT      NULL,
    [b_id]    INT      NULL,
    [SP]      MONEY    NULL,
    [SC]      MONEY    NULL,
    [FactPay] MONEY    DEFAULT (0) NULL
);

