CREATE TABLE [ELoadMenager].[report_history] (
    [rhID]        INT             IDENTITY (1, 1) NOT NULL,
    [object_ID]   INT             NULL,
    [DT]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [Host]        VARCHAR (100)   DEFAULT (host_name()) NULL,
    [Application] VARCHAR (500)   DEFAULT (app_name()) NULL,
    [OP]          INT             NOT NULL,
    [report]      VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([rhID] ASC)
);

