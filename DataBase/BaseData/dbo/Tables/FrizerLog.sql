CREATE TABLE [dbo].[FrizerLog] (
    [FLid]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME     DEFAULT (getdate()) NULL,
    [OP]      INT          NULL,
    [Act]     VARCHAR (10) NULL,
    [Comp]    VARCHAR (16) NULL,
    [Param1]  VARCHAR (24) NULL,
    [Comment] VARCHAR (32) NULL,
    UNIQUE NONCLUSTERED ([FLid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'комментарий к действию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerLog', @level2type = N'COLUMN', @level2name = N'Comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'действие', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerLog', @level2type = N'COLUMN', @level2name = N'Act';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id оператора вносившего правку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerLog', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerLog', @level2type = N'COLUMN', @level2name = N'ND';

