CREATE TABLE [warehouse].[sklad_gang_history] (
    [sgID]        INT             IDENTITY (1, 1) NOT NULL,
    [dt_create]   DATETIME        DEFAULT (getdate()) NOT NULL,
    [host_create] VARCHAR (100)   DEFAULT (host_name()) NOT NULL,
    [spks]        VARCHAR (MAX)   NULL,
    [skladlist]   NVARCHAR (1000) DEFAULT ('') NOT NULL,
    PRIMARY KEY CLUSTERED ([sgID] ASC)
);

