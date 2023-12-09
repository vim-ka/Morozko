CREATE TABLE [dbo].[Agents] (
    [AG_ID]      SMALLINT     IDENTITY (1, 1) NOT NULL,
    [SV_ID]      INT          CONSTRAINT [DF__Agents__SV_ID__77FFC2B3] DEFAULT ((0)) NOT NULL,
    [Fam]        VARCHAR (50) NULL,
    [Perc]       FLOAT (53)   NULL,
    [Phone]      VARCHAR (40) NULL,
    [LimitGSM]   FLOAT (53)   CONSTRAINT [DF__Agents__LimitGSM__770B9E7A] DEFAULT ((0)) NULL,
    [FrizPlan]   FLOAT (53)   NULL,
    [OtherPlan]  FLOAT (53)   NULL,
    [part]       FLOAT (53)   CONSTRAINT [DF__Agents__part__45A94D10] DEFAULT ((0.8)) NULL,
    [BonusDeb]   MONEY        CONSTRAINT [DF__Agents__BonusDeb__7A1D154F] DEFAULT ((0)) NULL,
    [BonusVend]  MONEY        CONSTRAINT [DF__Agents__BonusVen__7B113988] DEFAULT ((0)) NULL,
    [BonusMoroz] MONEY        CONSTRAINT [DF__Agents__BonusMor__7C055DC1] DEFAULT ((0)) NULL,
    [BonusPlan]  MONEY        CONSTRAINT [DF__Agents__BonusPla__7CF981FA] DEFAULT ((0)) NULL,
    [Remark]     VARCHAR (20) NULL,
    [Oklad]      MONEY        CONSTRAINT [DF__Agents__Oklad__7DEDA633] DEFAULT ((0)) NULL,
    [AGPhone]    VARCHAR (50) NULL,
    [CoefDist]   INT          CONSTRAINT [DF__Agents__CoefDist__43F6DA1F] DEFAULT ((0)) NULL,
    [Super]      BIT          DEFAULT ((0)) NULL,
    [uin]        INT          NULL,
    CONSTRAINT [PK_AGENTS] PRIMARY KEY CLUSTERED ([AG_ID] ASC),
    CONSTRAINT [FK_AGENTS_RLSHSV_AG_SUPERVIS] FOREIGN KEY ([SV_ID]) REFERENCES [dbo].[SuperVis] ([SV_ID])
);


GO
CREATE NONCLUSTERED INDEX [RlshSV_AG_FK]
    ON [dbo].[Agents]([SV_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэф. дальности из таблицы CoefDist', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Agents', @level2type = N'COLUMN', @level2name = N'CoefDist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Agents', @level2type = N'COLUMN', @level2name = N'AGPhone';

