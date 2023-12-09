CREATE TABLE [dbo].[tempMode] (
    [tmID]   INT          IDENTITY (1, 1) NOT NULL,
    [tmName] VARCHAR (50) NULL,
    [minT]   VARCHAR (10) NULL,
    [maxT]   VARCHAR (10) NULL,
    CONSTRAINT [PK_tempMode_tmID] PRIMARY KEY CLUSTERED ([tmID] ASC)
);

