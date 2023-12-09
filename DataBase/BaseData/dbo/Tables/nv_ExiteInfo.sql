CREATE TABLE [dbo].[nv_ExiteInfo] (
    [datnom] BIGINT       NULL,
    [hitag]  INT          NULL,
    [PLU]    VARCHAR (16) NULL
);


GO
CREATE NONCLUSTERED INDEX [nv_ExiteInfo_idx]
    ON [dbo].[nv_ExiteInfo]([datnom] ASC, [hitag] ASC);

