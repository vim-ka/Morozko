CREATE TABLE [dbo].[DefconAppendix] (
    [daID]     INT            IDENTITY (1, 1) NOT NULL,
    [Dck]      INT            NULL,
    [BrMaster] INT            NULL,
    [NDS]      BIT            DEFAULT ((1)) NULL,
    [OurPerc]  DECIMAL (6, 4) CONSTRAINT [DF__DefconApp__OurPe__1019A56B] DEFAULT ((10.0)) NULL,
    [Pay1KG]   MONEY          DEFAULT ((0)) NULL,
    [Our_ID]   SMALLINT       DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([daID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DefconAppendix_uq]
    ON [dbo].[DefconAppendix]([Dck] ASC, [BrMaster] ASC, [OurPerc] ASC, [Our_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'Pay1KG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наше вознаграждение за логистические услуги, %', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'OurPerc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если =0, то НДС из SP вычитаем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Мастер сети покупателей, или сам покупатель.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'BrMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ договора типа 5 или 6 с поставщиком', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'Dck';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ п/п', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefconAppendix', @level2type = N'COLUMN', @level2name = N'daID';

