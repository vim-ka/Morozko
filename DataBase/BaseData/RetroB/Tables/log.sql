CREATE TABLE [RetroB].[log] (
    [nmr]  INT           IDENTITY (1, 1) NOT NULL,
    [nd]   DATETIME      DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [Mess] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([nmr] ASC)
);

