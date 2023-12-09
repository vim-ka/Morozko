CREATE TABLE [dbo].[tempLog] (
    [hrono] DATETIME      DEFAULT (getdate()) NULL,
    [mess]  VARCHAR (100) NULL,
    [Comp]  VARCHAR (30)  NULL
);

