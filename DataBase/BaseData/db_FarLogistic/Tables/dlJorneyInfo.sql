CREATE TABLE [db_FarLogistic].[dlJorneyInfo] (
    [IDReq]            INT           NULL,
    [Cost]             MONEY         NULL,
    [isCancel]         BIT           DEFAULT ((0)) NULL,
    [ComentCancel]     VARCHAR (300) NULL,
    [NumberLoad]       INT           NULL,
    [Usr]              INT           NULL,
    [CasherID]         INT           NULL,
    [MarshID]          INT           DEFAULT ((-1)) NULL,
    [isCommerce]       BIT           DEFAULT ((0)) NULL,
    [BasisIDReq]       INT           NULL,
    [FCount]           INT           NULL,
    [Weight]           FLOAT (53)    NULL,
    [VendorID]         INT           NULL,
    [FDateLoad]        DATETIME      NULL,
    [FDateUnLoad]      DATETIME      NULL,
    [FWeight]          FLOAT (53)    NULL,
    [TariffCost]       FLOAT (53)    NULL,
    [isSTO]            BIT           DEFAULT ((0)) NULL,
    [TTN]              VARCHAR (MAX) NULL,
    [JorneyTypeID]     INT           NULL,
    [TTNDate]          DATE          NULL,
    [PDistance]        INT           NULL,
    [PCost]            MONEY         NULL,
    [NumberWorks]      INT           CONSTRAINT [DF__dlJorneyI__IDReq__4675B61C] DEFAULT ((-1)) NULL,
    [TORG12]           VARCHAR (600) NULL,
    [CargoCost]        MONEY         NULL,
    [TempID]           INT           NULL,
    [DamageID]         INT           NULL,
    [MarshDocID]       INT           NULL,
    [LoadCargoStateID] INT           NULL,
    [CargoTypeID]      INT           NULL,
    [IDDriverQuality]  INT           DEFAULT ((1)) NULL,
    [MechID]           INT           NULL,
    [DepID]            INT           DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [dlJorneyInfo_idx]
    ON [db_FarLogistic].[dlJorneyInfo]([VendorID] ASC);


GO
CREATE TRIGGER db_FarLogistic.dlJorneyInfo_triu ON db_FarLogistic.dlJorneyInfo
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
if UPDATE(NumberLoad)
begin
declare @n int 
declare @c int 
declare @idreq int
select @n=numberload from inserted
select @idreq=idreq from inserted
select @c=2*count(ji.idreq) from db_FarLogistic.dlJorneyInfo ji where ji.MarshID=(select a.MarshID from db_FarLogistic.dlJorneyInfo a where a.IDReq=@idreq)
update db_FarLogistic.dlJorney set db_FarLogistic.dlJorney.NumbForRace=@n
where db_FarLogistic.dlJorney.IDReq=@idreq and db_FarLogistic.dlJorney.IDdlPointAction=2
update db_FarLogistic.dlJorney set db_FarLogistic.dlJorney.NumbForRace=@c-@n+1
where db_FarLogistic.dlJorney.IDReq=@idreq and db_FarLogistic.dlJorney.IDdlPointAction=5
end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'качество работы водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'IDDriverQuality';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип груза', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'CargoTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'состояние груза при погрузке', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'LoadCargoStateID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'маршрутные документы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'MarshDocID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентифиеатор повреждений', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'DamageID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'температурный режим', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'TempID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'стоимость груза', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'CargoCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'торг 12', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'TORG12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер работы к оплате', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'NumberWorks';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'рассчетная стоимость', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'PCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'рассчетное расстояние', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'PDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата передачи ттн', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'TTNDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип заявки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'JorneyTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер ттн', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'TTN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена за километр', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'TariffCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тоннаж', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фактическая загрузка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'FCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор заявки прихода', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'BasisIDReq';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Флаг коммерческого рейса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'isCommerce';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'MarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор контрагента', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'CasherID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Последний изменивший', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'Usr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер погрузки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'NumberLoad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий отмены', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'ComentCancel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Рейс отменен', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'isCancel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость рейса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор заявки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorneyInfo', @level2type = N'COLUMN', @level2name = N'IDReq';

