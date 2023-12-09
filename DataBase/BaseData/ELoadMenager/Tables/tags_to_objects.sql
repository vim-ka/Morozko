CREATE TABLE [ELoadMenager].[tags_to_objects] (
    [tag_id]      INT           NOT NULL,
    [object_id]   INT           NOT NULL,
    [DT]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [Host]        VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [Application] VARCHAR (100) CONSTRAINT [DF__tags_to_o__Appli__130CB75D] DEFAULT (app_name()) NOT NULL,
    [OP]          INT           NOT NULL,
    CONSTRAINT [tags_to_objects_pk] PRIMARY KEY CLUSTERED ([tag_id] ASC, [object_id] ASC),
    CONSTRAINT [tags_to_objects_fk] FOREIGN KEY ([object_id]) REFERENCES [ELoadMenager].[objects] ([ID]) ON DELETE CASCADE,
    CONSTRAINT [tags_to_objects_fk2] FOREIGN KEY ([tag_id]) REFERENCES [ELoadMenager].[tags] ([ID]) ON DELETE CASCADE
);

