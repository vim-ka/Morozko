CREATE TABLE [dbo].[exite_orderStatus] (
    [id]         INT          NOT NULL,
    [text]       VARCHAR (32) NOT NULL,
    [StatusName] VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'статус документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderStatus', @level2type = N'COLUMN', @level2name = N'text';

