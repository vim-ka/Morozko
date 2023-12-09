CREATE TABLE [dbo].[ServicePrice] (
    [spID]    INT      IDENTITY (1, 1) NOT NULL,
    [DCK]     INT      NULL,
    [stID]    INT      NULL,
    [price]   MONEY    NULL,
    [ndStart] DATETIME NULL,
    [ndEnd]   DATETIME NULL,
    CONSTRAINT [PK_ServicePrice_spID] PRIMARY KEY CLUSTERED ([spID] ASC)
);

