CREATE TABLE [dbo].[skladrooms] (
    [srID]      INT           IDENTITY (1, 1) NOT NULL,
    [room_code] NVARCHAR (5)  NOT NULL,
    [room_name] NVARCHAR (50) DEFAULT ('') NOT NULL
);

