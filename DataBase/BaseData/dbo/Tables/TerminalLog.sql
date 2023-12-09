CREATE TABLE [dbo].[TerminalLog] (
    [tlDI]      INT           IDENTITY (1, 1) NOT NULL,
    [skladlist] VARCHAR (500) NULL,
    [nd]        DATETIME      NULL,
    [type]      INT           NULL,
    [comp]      VARCHAR (30)  DEFAULT (host_name()) NULL,
    PRIMARY KEY CLUSTERED ([tlDI] ASC)
);

