CREATE TABLE [NearLogistic].[MarshRequestsCancel] (
    [mrcID]   INT           IDENTITY (1, 1) NOT NULL,
    [mhID]    INT           NOT NULL,
    [mrID]    INT           NOT NULL,
    [ResID]   INT           NOT NULL,
    [Remark]  VARCHAR (500) DEFAULT ('') NULL,
    [OP]      INT           NOT NULL,
    [Comp]    VARCHAR (30)  DEFAULT (host_name()) NULL,
    [AppName] VARCHAR (100) DEFAULT (app_name()) NULL,
    [DT]      DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [MarshRequestsCancel_pk] PRIMARY KEY CLUSTERED ([mrcID] ASC)
);

