CREATE TABLE [dbo].[SertifStorageType] (
    [StorageTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [type]          SMALLINT     NULL,
    [name]          VARCHAR (50) NULL,
    [description]   VARCHAR (50) NULL,
    CONSTRAINT [PK_SertifStorageType_StorageTypeID] PRIMARY KEY CLUSTERED ([StorageTypeID] ASC)
);

