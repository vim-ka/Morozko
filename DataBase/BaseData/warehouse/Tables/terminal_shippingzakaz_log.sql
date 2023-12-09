CREATE TABLE [warehouse].[terminal_shippingzakaz_log] (
    [logID] INT             IDENTITY (1, 1) NOT NULL,
    [comp]  VARCHAR (50)    DEFAULT (host_name()) NOT NULL,
    [dt]    DATETIME        DEFAULT (getdate()) NOT NULL,
    [nzID]  INT             NULL,
    [ves]   DECIMAL (10, 3) NULL,
    [op]    INT             NULL,
    [spk]   INT             NULL,
    [msg]   VARCHAR (200)   NULL,
    [done]  BIT             NULL,
    CONSTRAINT [PK__Shipping__7839F62DD5F218F5] PRIMARY KEY CLUSTERED ([logID] DESC)
);

