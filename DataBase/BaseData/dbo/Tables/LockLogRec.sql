CREATE TABLE [dbo].[LockLogRec] (
    [ISPR]      INT            IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME       DEFAULT (getdate()) NULL,
    [user_name] NVARCHAR (256) DEFAULT (suser_sname()) NULL,
    [host_name] NCHAR (30)     DEFAULT (host_name()) NULL,
    [app_name]  NVARCHAR (128) DEFAULT (app_name()) NULL,
    [type]      SMALLINT       NULL,
    [llid]      INT            NOT NULL
);

