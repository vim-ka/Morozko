CREATE TABLE [dbo].[SertifLogWork] (
    [logID]   INT           IDENTITY (1, 1) NOT NULL,
    [YYMM]    INT           NOT NULL,
    [TypeID]  INT           NOT NULL,
    [OP]      INT           NOT NULL,
    [Counter] INT           NOT NULL,
    [Comment] VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([logID] ASC)
);

