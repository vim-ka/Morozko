CREATE TABLE [dbo].[reporter] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [docname]  VARCHAR (255)   NULL,
    [filename] VARCHAR (255)   NULL,
    [filetype] VARCHAR (4)     NULL,
    [filebody] VARBINARY (MAX) NULL,
    [nd]       DATETIME        DEFAULT (getdate()) NULL,
    [docsize]  INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

