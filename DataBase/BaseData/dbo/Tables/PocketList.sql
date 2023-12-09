CREATE TABLE [dbo].[PocketList] (
    [PNo]        INT          IDENTITY (1, 1) NOT NULL,
    [PName]      VARCHAR (10) NULL,
    [SerNo]      VARCHAR (20) NULL,
    [ServerName] VARCHAR (10) NULL,
    [Available]  BIT          NULL,
    [PModel]     VARCHAR (20) NULL,
    UNIQUE NONCLUSTERED ([PNo] ASC)
);

