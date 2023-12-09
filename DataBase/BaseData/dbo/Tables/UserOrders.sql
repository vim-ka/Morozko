CREATE TABLE [dbo].[UserOrders] (
    [uoID]   INT          IDENTITY (1, 1) NOT NULL,
    [uin]    INT          NULL,
    [Our_ID] SMALLINT     NULL,
    [Prikaz] VARCHAR (50) NULL,
    [Day0]   DATETIME     NULL,
    [Day1]   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([uoID] ASC)
);

