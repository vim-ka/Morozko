CREATE TABLE [dbo].[PreOrderStatus] (
    [PoStatus]   INT          IDENTITY (1, 1) NOT NULL,
    [StatusName] VARCHAR (40) NULL,
    PRIMARY KEY CLUSTERED ([PoStatus] ASC)
);

