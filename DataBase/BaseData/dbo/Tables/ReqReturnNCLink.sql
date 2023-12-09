CREATE TABLE [dbo].[ReqReturnNCLink] (
    [id]     INT IDENTITY (1, 1) NOT NULL,
    [rk]     INT DEFAULT ((-1)) NULL,
    [datnom] INT DEFAULT ((-1)) NULL,
    CONSTRAINT [ReqReturnNCLink_pk] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ReqReturnNCLink_uq]
    ON [dbo].[ReqReturnNCLink]([datnom] ASC);


GO
CREATE NONCLUSTERED INDEX [ReqReturnNCLink_idx]
    ON [dbo].[ReqReturnNCLink]([rk] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код накладной на возврат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnNCLink', @level2type = N'COLUMN', @level2name = N'datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код заявки на возврат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnNCLink', @level2type = N'COLUMN', @level2name = N'rk';

