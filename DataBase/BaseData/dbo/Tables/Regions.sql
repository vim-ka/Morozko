CREATE TABLE [dbo].[Regions] (
    [Reg_ID]    VARCHAR (5)     NOT NULL,
    [Place]     VARCHAR (250)   NULL,
    [Rast]      NUMERIC (10, 2) NULL,
    [MainReg]   VARCHAR (5)     NULL,
    [Priority]  SMALLINT        DEFAULT ((1)) NULL,
    [isDel]     BIT             DEFAULT ((0)) NOT NULL,
    [SkladReg]  VARCHAR (5)     CONSTRAINT [DF__Regions__ScladRe__3ABAB604_copy] DEFAULT ('') NULL,
    [RegionID]  INT             IDENTITY (1, 1) NOT NULL,
    [sregionID] INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Regions_pk_copy] PRIMARY KEY CLUSTERED ([Reg_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приоритет региона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Regions', @level2type = N'COLUMN', @level2name = N'Priority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код региона уровень 0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Regions', @level2type = N'COLUMN', @level2name = N'MainReg';

