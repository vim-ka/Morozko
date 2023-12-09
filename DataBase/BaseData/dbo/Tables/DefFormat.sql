CREATE TABLE [dbo].[DefFormat] (
    [dfID]   SMALLINT     IDENTITY (1, 1) NOT NULL,
    [dfName] VARCHAR (80) NULL,
    [Levl]   SMALLINT     CONSTRAINT [DF__DefFormat__Levl__4E00FDF4] DEFAULT ((0)) NULL,
    [Parent] SMALLINT     NULL,
    [SubID]  TINYINT      CONSTRAINT [DF__DefFormat__SubID__55A21FBC] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__DefForma__DBF3A352A65229A6] PRIMARY KEY CLUSTERED ([dfID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Родительский формат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefFormat', @level2type = N'COLUMN', @level2name = N'Parent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уровень. 0-верхний.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefFormat', @level2type = N'COLUMN', @level2name = N'Levl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Название формата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefFormat', @level2type = N'COLUMN', @level2name = N'dfName';

