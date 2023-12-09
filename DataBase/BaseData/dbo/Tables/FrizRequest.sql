CREATE TABLE [dbo].[FrizRequest] (
    [rid]           INT             IDENTITY (1, 1) NOT NULL,
    [rcmplxid]      INT             NULL,
    [rdt]           DATETIME        DEFAULT (getdate()) NULL,
    [rneedact]      INT             NULL,
    [rdepid]        INT             NULL,
    [rqty]          INT             NULL,
    [rnazn]         INT             NULL,
    [rreasonact]    INT             NULL,
    [rtpcode]       INT             NULL,
    [rtpaddr]       VARCHAR (300)   NULL,
    [rtpcontact]    VARCHAR (40)    NULL,
    [rtpcontactd]   VARCHAR (40)    NULL,
    [rtpphone]      VARCHAR (50)    NULL,
    [rtpag_id]      INT             NULL,
    [rtpag_phone]   VARCHAR (50)    NULL,
    [ractdate]      DATETIME        NULL,
    [rexecdate]     DATETIME        NULL,
    [rohocomm]      VARCHAR (1000)  NULL,
    [radmcomm]      VARCHAR (1000)  NULL,
    [rinvnom]       VARCHAR (100)   NULL,
    [rdatebefore]   BIT             NULL,
    [rstatus]       INT             NULL,
    [rsost]         INT             NULL,
    [rother]        VARCHAR (300)   NULL,
    [rprim]         VARCHAR (300)   NULL,
    [rdel]          VARCHAR (1)     DEFAULT ((0)) NULL,
    [ruin]          INT             NULL,
    [rbrand]        INT             NULL,
    [rfrizertip]    INT             NULL,
    [rtpcode2]      INT             NULL,
    [rtpaddr2]      VARCHAR (300)   NULL,
    [rtpcontact2]   VARCHAR (40)    NULL,
    [rtpcontactd2]  VARCHAR (40)    NULL,
    [rtpphone2]     VARCHAR (50)    NULL,
    [rtpag_id2]     INT             NULL,
    [rtpag_phone2]  VARCHAR (50)    NULL,
    [rdop]          VARCHAR (300)   NULL,
    [rmorozhstatus] INT             NULL,
    [rmorozhcomm]   VARCHAR (1000)  NULL,
    [rfordoc]       INT             DEFAULT ((0)) NULL,
    [p_id]          INT             NULL,
    [rotlozh]       BIT             DEFAULT ((0)) NULL,
    [needoborot]    NUMERIC (10, 2) DEFAULT ((0)) NULL,
    [mhID]          INT             DEFAULT ((0)) NOT NULL,
    [fmtidx]        INT             DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([rid] ASC),
    CONSTRAINT [FrizRequest_uq] UNIQUE NONCLUSTERED ([rcmplxid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [FrizRequest_idx]
    ON [dbo].[FrizRequest]([rcmplxid] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_mgid]
    ON [dbo].[FrizRequest]([mhID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предполагаемый оборот', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'needoborot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак отложенной заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rotlozh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Инициатор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Реальное действие или документальное', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rfordoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Собственный комментарий для мороженого', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rmorozhcomm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Собственный статус для мороженого', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rmorozhstatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Блок характеристик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rdop';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код второго контрагента из Def', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rtpcode2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rfrizertip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код брэнда ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rbrand';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не используется', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'ruin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак отмененной заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rdel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rprim';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доп. характеристики', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rother';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние оборудования (новый, б/у)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rsost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на справочник статусов заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rstatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполнение до желаемой даты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rdatebefore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Инвентарные номера через разделитель (,)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rinvnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коммент администратора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'radmcomm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коммент ОХО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rohocomm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата фактического исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rexecdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата совершения действия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'ractdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rtpag_phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rtpag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента (из Def)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rtpcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rreasonact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Назначение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rnazn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во единиц оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rqty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Торговый отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rdepid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Требуемое действие', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rneedact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rdt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizRequest', @level2type = N'COLUMN', @level2name = N'rcmplxid';

