CREATE TABLE [dbo].[Nomen3] (
    [b_id]     INT           NULL,
    [Hitag]    INT           NULL,
    [Name]     VARCHAR (90)  NULL,
    [NameTemp] VARCHAR (100) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [nm3_idx]
    ON [dbo].[Nomen3]([b_id] ASC, [Hitag] ASC);

