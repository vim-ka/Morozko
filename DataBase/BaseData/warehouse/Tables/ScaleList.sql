CREATE TABLE [warehouse].[ScaleList] (
    [name]  VARCHAR (50)  NULL,
    [IP]    VARCHAR (15)  NULL,
    [Descr] VARCHAR (500) NULL,
    [id]    INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [SkaleList_pk] PRIMARY KEY CLUSTERED ([id] ASC)
);

