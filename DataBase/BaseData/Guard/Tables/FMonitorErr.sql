CREATE TABLE [Guard].[FMonitorErr] (
    [meID]     INT            IDENTITY (1, 1) NOT NULL,
    [Hrono]    DATETIME       DEFAULT (getdate()) NULL,
    [TaskName] VARCHAR (150)  NULL,
    [Txt]      VARCHAR (5000) NULL,
    [PicName]  VARCHAR (150)  NULL,
    PRIMARY KEY CLUSTERED ([meID] ASC)
);

