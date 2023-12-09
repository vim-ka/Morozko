CREATE TABLE [dbo].[nv_join] (
    [nvj]       INT             IDENTITY (1, 1) NOT NULL,
    [datnom]    BIGINT          NULL,
    [refdatnom] BIGINT          NULL,
    [tekid]     INT             NULL,
    [reftekid]  INT             NULL,
    [weight]    DECIMAL (10, 3) NULL,
    CONSTRAINT [nv_join_pk] PRIMARY KEY CLUSTERED ([nvj] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nv_join_idx4]
    ON [dbo].[nv_join]([reftekid] ASC);


GO
CREATE NONCLUSTERED INDEX [nv_join_idx3]
    ON [dbo].[nv_join]([tekid] ASC);


GO
CREATE NONCLUSTERED INDEX [nv_join_idx]
    ON [dbo].[nv_join]([datnom] ASC);


GO
CREATE NONCLUSTERED INDEX [nv_join_idx2]
    ON [dbo].[nv_join]([refdatnom] ASC);

