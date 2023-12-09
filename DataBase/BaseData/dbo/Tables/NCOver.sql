CREATE TABLE [dbo].[NCOver] (
    [DatNom]  INT            NOT NULL,
    [ND]      DATETIME       NULL,
    [NNak]    INT            NULL,
    [B_id]    INT            NOT NULL,
    [SP]      MONEY          DEFAULT ((0)) NULL,
    [SC]      MONEY          DEFAULT ((0)) NULL,
    [Fact]    MONEY          DEFAULT ((0)) NULL,
    [Izmen]   MONEY          DEFAULT ((0)) NULL,
    [Srok]    INT            DEFAULT ((0)) NULL,
    [NDDolg]  SMALLINT       DEFAULT ((0)) NULL,
    [Overdue] MONEY          DEFAULT ((0)) NULL,
    [Extra]   NUMERIC (6, 2) CONSTRAINT [DF__NCOver__Extra__2C146396] DEFAULT ((0)) NULL,
    CONSTRAINT [NCOver_pk] PRIMARY KEY CLUSTERED ([DatNom] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочка в руб.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCOver', @level2type = N'COLUMN', @level2name = N'Overdue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочено в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCOver', @level2type = N'COLUMN', @level2name = N'NDDolg';

