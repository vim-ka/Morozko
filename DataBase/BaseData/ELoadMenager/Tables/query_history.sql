CREATE TABLE [ELoadMenager].[query_history] (
    [qhID]        INT            IDENTITY (1, 1) NOT NULL,
    [object_ID]   INT            NULL,
    [QueryText]   VARCHAR (5000) NULL,
    [DT]          DATETIME       DEFAULT (getdate()) NOT NULL,
    [Host]        VARCHAR (100)  DEFAULT (host_name()) NULL,
    [Application] VARCHAR (500)  DEFAULT (app_name()) NULL,
    [OP]          INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([qhID] ASC)
);

