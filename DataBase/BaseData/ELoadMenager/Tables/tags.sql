CREATE TABLE [ELoadMenager].[tags] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50)  NOT NULL,
    [DT_publish]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [Host]        VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [Application] VARCHAR (100) DEFAULT (app_name()) NOT NULL,
    [OP]          INT           NOT NULL,
    [isDel]       BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [tegs_pk] PRIMARY KEY CLUSTERED ([ID] ASC),
    UNIQUE NONCLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [tags_idx]
    ON [ELoadMenager].[tags]([Name] ASC);

