CREATE TABLE [RetroB].[rb_Buyers] (
    [RbId]    INT NULL,
    [Pin]     INT NULL,
    [NetMode] BIT DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [rb_Buyers_idx]
    ON [RetroB].[rb_Buyers]([RbId] ASC);

