CREATE TABLE [dbo].[MarshVedOpl] (
    [voId]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]      DATETIME     CONSTRAINT [DF__MarshVedOpla__ND__1E7B3CAD] DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [Tm]      CHAR (8)     CONSTRAINT [DF__MarshVedOpla__Tm__1D871874] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [act]     VARCHAR (3)  NULL,
    [vedNo]   INT          NOT NULL,
    [Op]      INT          NULL,
    [Remark]  VARCHAR (60) NULL,
    [StartND] DATETIME     NOT NULL,
    [EndND]   DATETIME     NOT NULL,
    CONSTRAINT [MarshVedOplata_pk] PRIMARY KEY CLUSTERED ([voId] ASC),
    CONSTRAINT [MarshVedOplata_uq] UNIQUE NONCLUSTERED ([vedNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата завершения периода расчета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshVedOpl', @level2type = N'COLUMN', @level2name = N'EndND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала периода расчета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshVedOpl', @level2type = N'COLUMN', @level2name = N'StartND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ ведомости оплат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshVedOpl', @level2type = N'COLUMN', @level2name = N'vedNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип ведомости
DRV- вед оплат по водителям
CRR- вед оплат по ИПешникам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshVedOpl', @level2type = N'COLUMN', @level2name = N'act';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица по оплатам за рейсы (ведомость оплат)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshVedOpl';

