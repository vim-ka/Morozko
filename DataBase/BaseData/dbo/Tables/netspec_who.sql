CREATE TABLE [dbo].[netspec_who] (
    [nmid]    INT NULL,
    [pin]     INT NULL,
    [NetFlag] BIT DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [netspec_who_idx3]
    ON [dbo].[netspec_who]([NetFlag] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec_who_idx2]
    ON [dbo].[netspec_who]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec_who_idx]
    ON [dbo].[netspec_who]([nmid] ASC);

