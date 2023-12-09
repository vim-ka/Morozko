CREATE TABLE [dbo].[BrTov] (
    [Tov]     INT          IDENTITY (0, 1) NOT NULL,
    [TovName] VARCHAR (30) DEFAULT ('') NULL,
    PRIMARY KEY CLUSTERED ([Tov] ASC)
);

