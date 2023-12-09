CREATE TABLE [dbo].[tmpUpdateNomen] (
    [comp] VARCHAR (500) DEFAULT (host_name()) NULL,
    [prg]  VARCHAR (500) DEFAULT (app_name()) NULL,
    [dt]   DATETIME      DEFAULT (getdate()) NULL
);

