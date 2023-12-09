CREATE TABLE [ELoadMenager].[users_to_objects] (
    [object_id]   INT           NOT NULL,
    [user_id]     INT           NOT NULL,
    [DT]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [Host]        VARCHAR (30)  DEFAULT (host_name()) NOT NULL,
    [Application] VARCHAR (100) DEFAULT (app_name()) NOT NULL,
    [OP]          INT           NOT NULL,
    CONSTRAINT [users_to_objects_pk] PRIMARY KEY CLUSTERED ([object_id] ASC, [user_id] ASC),
    CONSTRAINT [users_to_objects_fk] FOREIGN KEY ([object_id]) REFERENCES [ELoadMenager].[objects] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [users_to_objects_idx2]
    ON [ELoadMenager].[users_to_objects]([user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [users_to_objects_idx]
    ON [ELoadMenager].[users_to_objects]([object_id] ASC);

