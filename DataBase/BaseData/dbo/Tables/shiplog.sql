CREATE TABLE [dbo].[shiplog] (
    [nd]    DATETIME        DEFAULT (getdate()) NULL,
    [comp]  VARCHAR (30)    NULL,
    [newid] INT             NULL,
    [hitag] INT             NULL,
    [price] DECIMAL (15, 5) NULL,
    [cost]  DECIMAL (15, 5) NULL
);

