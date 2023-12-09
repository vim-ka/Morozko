CREATE TABLE [dbo].[ServiceType] (
    [stID]   INT           IDENTITY (1, 1) NOT NULL,
    [stName] VARCHAR (100) NULL,
    [kol]    BIT           DEFAULT ((0)) NULL,
    [income] BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ServiceType_stID] PRIMARY KEY CLUSTERED ([stID] ASC)
);

