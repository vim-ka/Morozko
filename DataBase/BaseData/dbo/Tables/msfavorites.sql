CREATE TABLE [dbo].[msfavorites] (
    [ID]         BIGINT IDENTITY (1, 1) NOT NULL,
    [fav_name]   TEXT   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [fav_source] TEXT   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [fav_path]   TEXT   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

