CREATE TABLE [dbo].[PhoneDet] (
    [DetID]       INT            IDENTITY (1, 1) NOT NULL,
    [DogNo]       VARCHAR (20)   NULL,
    [Number]      VARCHAR (20)   NULL,
    [ND]          DATETIME       NULL,
    [Tm]          VARCHAR (8)    NULL,
    [Dur]         VARCHAR (8)    NULL,
    [DurRound]    NUMERIC (5, 2) NULL,
    [Cost]        MONEY          NULL,
    [NumberEnt]   VARCHAR (20)   NULL,
    [NumberProc]  VARCHAR (20)   NULL,
    [Type]        VARCHAR (30)   NULL,
    [Remark]      VARCHAR (100)  NULL,
    [ConnectType] VARCHAR (50)   NULL,
    [Value]       NUMERIC (5, 2) NULL,
    UNIQUE NONCLUSTERED ([DetID] ASC)
);

