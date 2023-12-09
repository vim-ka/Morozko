CREATE TABLE [dbo].[DOT_Kassa] (
    [KassId] INT             IDENTITY (1, 1) NOT NULL,
    [Dot]    INT             NULL,
    [Rid]    INT             DEFAULT ((0)) NULL,
    [ND]     DATETIME        NULL,
    [Ncom]   INT             DEFAULT ((0)) NULL,
    [Ncod]   INT             DEFAULT ((0)) NULL,
    [Plata]  DECIMAL (12, 2) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([KassId] ASC)
);

