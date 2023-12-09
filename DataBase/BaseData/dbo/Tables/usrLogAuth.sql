CREATE TABLE [dbo].[usrLogAuth] (
    [nd]     DATETIME     DEFAULT (getdate()) NULL,
    [uin]    INT          NULL,
    [prg]    VARCHAR (16) NULL,
    [status] VARCHAR (50) NULL,
    [Comp]   VARCHAR (32) DEFAULT (host_name()) NULL,
    [p_id]   INT          NULL
);

