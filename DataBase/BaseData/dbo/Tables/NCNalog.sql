CREATE TABLE [dbo].[NCNalog] (
    [tdId]   INT   IDENTITY (1, 1) NOT NULL,
    [DatNom] INT   NULL,
    [Sp]     MONEY CONSTRAINT [DF__NCNalog__Sp__10F65906] DEFAULT ((0)) NULL,
    [NDS18]  MONEY CONSTRAINT [DF__NCNalog__NDS18__0F0E1094] DEFAULT ((0)) NULL,
    [NDS10]  MONEY CONSTRAINT [DF__NCNalog__NDS10__0E19EC5B] DEFAULT ((0)) NULL,
    [NDS0]   MONEY CONSTRAINT [DF__NCNalog__NDS0__100234CD] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Детализация по НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCNalog';

