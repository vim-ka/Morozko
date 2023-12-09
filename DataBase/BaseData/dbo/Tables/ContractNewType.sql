CREATE TABLE [dbo].[ContractNewType] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [cshortnaim] VARCHAR (50)  NULL,
    [cfullnaim]  VARCHAR (200) NULL,
    [cusergroup] INT           DEFAULT ((16)) NULL,
    [cvisible]   BIT           DEFAULT ((1)) NULL,
    [hid]        INT           DEFAULT ((-1)) NULL,
    [ctimefor]   INT           DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

