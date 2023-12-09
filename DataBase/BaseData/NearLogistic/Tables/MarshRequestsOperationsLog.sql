CREATE TABLE [NearLogistic].[MarshRequestsOperationsLog] (
    [olID]          INT           IDENTITY (1, 1) NOT NULL,
    [nd]            DATETIME      DEFAULT (getdate()) NOT NULL,
    [host_]         VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [app]           VARCHAR (50)  DEFAULT (app_name()) NOT NULL,
    [op]            INT           NOT NULL,
    [mhid]          INT           DEFAULT ((0)) NOT NULL,
    [mhid_old]      INT           DEFAULT ((0)) NULL,
    [ids]           VARCHAR (MAX) NULL,
    [operationType] INT           NOT NULL,
    [ids_]          VARCHAR (MAX) NULL,
    [Remark]        VARCHAR (500) DEFAULT ('') NOT NULL
);

