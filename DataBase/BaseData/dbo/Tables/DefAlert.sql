CREATE TABLE [dbo].[DefAlert] (
    [DaID]       INT           IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME      NULL,
    [TM]         CHAR (8)      NULL,
    [Dck]        INT           NOT NULL,
    [Tip]        SMALLINT      NULL,
    [SourceOP]   INT           NULL,
    [StrMessage] VARCHAR (400) NULL,
    PRIMARY KEY CLUSTERED ([DaID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'>1000-моб.агенты, до 1000 - операторы, бухгалтеры и т.д.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefAlert', @level2type = N'COLUMN', @level2name = N'SourceOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-сверка ОК, 2-расх.<500р, 3-срочно сверить! ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefAlert', @level2type = N'COLUMN', @level2name = N'Tip';

