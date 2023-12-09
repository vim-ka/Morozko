CREATE TABLE [db_FarLogistic].[dlJorney] (
    [IDdlDelivPoint]  INT        NULL,
    [IDdlPointAction] INT        NULL,
    [Usr]             INT        NULL,
    [Numb]            INT        NULL,
    [IDReq]           INT        NULL,
    [NumbForRace]     INT        NULL,
    [PDate]           DATETIME   NULL,
    [FDate]           DATETIME   NULL,
    [PCount]          INT        NULL,
    [FCount]          INT        DEFAULT ((0)) NULL,
    [PWeight]         FLOAT (53) NULL,
    [FWeight]         FLOAT (53) DEFAULT ((0)) NULL,
    [NumberWorks]     INT        NULL,
    [DrvWorkQuality]  INT        DEFAULT ((1)) NULL,
    [isHide]          BIT        DEFAULT ((0)) NOT NULL,
    [JorneyID]        INT        IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [dlJorney_uq] UNIQUE NONCLUSTERED ([JorneyID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [dlJorney_idx2]
    ON [db_FarLogistic].[dlJorney]([FCount] ASC);


GO
CREATE NONCLUSTERED INDEX [dlJorney_idx]
    ON [db_FarLogistic].[dlJorney]([IDdlPointAction] ASC);


GO
CREATE TRIGGER [db_FarLogistic].[dlJorney_tri] ON [db_FarLogistic].[dlJorney]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
declare @n int
declare @IDReq int 
select @n=numb,@IDReq=IDReq  from inserted where numb is null
if not @IDReq is null
begin
	select @n=max(j.numb) from db_FarLogistic.dlJorney j where j.IDReq=@IDReq
  update db_FarLogistic.dlJorney set numb=@n+1 where db_FarLogistic.dlJorney.IDReq=@IDReq and db_FarLogistic.dlJorney.Numb is null
end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'скрыть в услуге', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'isHide';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'замечания водителю', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'DrvWorkQuality';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер работ', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'NumberWorks';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактическая дата исполнения этапа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'FDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'запланированная дата исполнения этапа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'PDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'порядок точки при обходе', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'NumbForRace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор заявки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'IDReq';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'порядок точки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'Numb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'пользователь', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'Usr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор действия на точке', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'IDdlPointAction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор точки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlJorney', @level2type = N'COLUMN', @level2name = N'IDdlDelivPoint';

