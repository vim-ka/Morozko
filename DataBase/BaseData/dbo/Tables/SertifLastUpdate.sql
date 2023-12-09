CREATE TABLE [dbo].[SertifLastUpdate] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [TableName]  VARCHAR (255) NULL,
    [Enterprise] VARCHAR (255) NULL,
    [LastUpdate] DATETIME      NULL,
    [HostName]   VARCHAR (50)  DEFAULT (host_name()) NULL,
    [Op]         INT           NULL,
    CONSTRAINT [PK_SertifLastUpdate_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

