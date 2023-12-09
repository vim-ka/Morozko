CREATE TABLE [db_FarLogistic].[dlMarsh] (
    [dlMarshID]       INT           NOT NULL,
    [pin]             INT           NULL,
    [IDdlVehicles]    INT           NULL,
    [IDdlDrivers]     INT           NULL,
    [IDdlMarshStatus] INT           NULL,
    [odo_beg_fact]    INT           NULL,
    [odo_end_fact]    INT           NULL,
    [dt_beg_fact]     DATETIME      NULL,
    [dt_beg_plan]     DATETIME      NULL,
    [dt_end_fact]     DATETIME      NULL,
    [dt_end_plan]     DATETIME      NULL,
    [idTrailer]       INT           NULL,
    [date_creation]   DATETIME      NULL,
    [IDUsrPwd]        INT           NULL,
    [PlanDistance]    INT           NULL,
    [PlanCost]        MONEY         NULL,
    [FactDistance]    INT           NULL,
    [FactCost]        MONEY         NULL,
    [Comment]         VARCHAR (100) NULL,
    [dt_cancel]       DATETIME      NULL,
    [SubMarsh]        BIT           CONSTRAINT [DF__dlMarsh__SubMars__26C80099] DEFAULT ((0)) NULL,
    [SubFirstName]    VARCHAR (30)  NULL,
    [SubMiddleName]   VARCHAR (30)  NULL,
    [SubSurname]      VARCHAR (30)  NULL,
    [SubPass]         VARCHAR (100) NULL,
    [SubDrvDoc]       VARCHAR (15)  NULL,
    [SubVehInfo]      VARCHAR (100) NULL,
    [SubTrailerInfo]  VARCHAR (100) NULL,
    [SubPhone]        VARCHAR (100) NULL,
    CONSTRAINT [dlMarsh_uq_dlMarsh] UNIQUE NONCLUSTERED ([dlMarshID] ASC)
);


GO
CREATE TRIGGER [db_FarLogistic].tri_dlMarsh_INS_A
ON db_FarLogistic.dlMarsh
AFTER INSERT
AS
BEGIN
  INSERT INTO [db_FarLogistic].[dlMarshLog](
    dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
    ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
    ,SubPhone,Action
    )
  SELECT dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
         ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
         ,SubPhone,'INS'
  FROM [INSERTED]
END
GO
CREATE TRIGGER db_FarLogistic.tri_dlMarsh_UPD_A ON db_FarLogistic.dlMarsh
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
  INSERT INTO [db_FarLogistic].[dlMarshLog](
    dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
    ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
    ,SubPhone,Action
    )
  SELECT dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
         ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
         ,SubPhone,'UPD_F'
  FROM [DELETED]
  
  INSERT INTO [db_FarLogistic].[dlMarshLog](
    dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
    ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
    ,SubPhone,Action
    )
  SELECT dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
         ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
         ,SubPhone,'UPD_T'
  FROM [INSERTED]
  
  
  declare @v_id int, @dr_id int, @status_old int, @status_new int
  select @v_id=i.iddlvehicles, @dr_id=i.iddldrivers, @status_new=i.IDdlMarshStatus from [inserted] i
  select @status_old=d.IDdlMarshStatus from [deleted] d
  if exists(select 1 from db_farlogistic.dldrivetruck where v_id=@v_id)
  begin
  	if @status_new=2 and @status_old=1
    begin
      if not exists(select 1 from db_farlogistic.dldrivetruck where v_id=@v_id and drid=@dr_id)
      begin
        declare @msg nvarchar(100) =''
        select @msg=isnull(d.Surname,'')+' '+isnull(d.Firstname,'')+' '+isnull(d.Middlename,'')+' ,в\у '+isnull(d.DriverDoc,'<..>')+' '+char(13)+
                    'т\с '+isnull(v.model,'<..>')+' рег.ном '+isnull(v.regnom,'<..>')
        from [inserted] i
        join db_farlogistic.dlvehicles v on v.dlVehiclesID=i.IDdlVehicles
        join db_FarLogistic.dlDrivers d on d.ID=i.IDdlDrivers
        
        insert into  dbo.Requests(ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec,  KsOper,  RemarkFin, PlanND, [Status], RealND, 
                 RemarkMain, ReqAvail, Nal,  ReqAv,  FactND,  Period,  RemarkMtr,  Rs,  Rf,  [Sent],  SalaryMonth,  PersonnelDepMessage,  [Type],  
                 tm,  rql, Bypass,  Itsright,  [Data],  PlataOver,  ByCall,  Otv2,  Tip2,  Data2,  ResFin2,  Prior2,  Locked,  ResFin2ND,  compname) 
        values (getdate(), 10, 14, 78,'Контроль за заполнением и сдачей водителями акта приема передачи автомобиля', 'Сформировано автоматически', getdate(), 0,'',NULL,'',getdate(),1,getdate(),'',0,0,0,NULL,0,'',1,0,0,0,'',0,
                 dbo.time(),0,0,0,'',0,0, 1693,202,@msg,0,0,0,NULL,host_name())
      end
    end
  end
END
GO
CREATE TRIGGER [db_FarLogistic].tri_dlMarsh_DEL_A
ON db_FarLogistic.dlMarsh
AFTER DELETE
AS
BEGIN
  INSERT INTO [db_FarLogistic].[dlMarshLog](
    dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
    ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
    ,SubPhone,Action
    )
  SELECT dlMarshID,pin,IDdlVehicles,IDdlDrivers,IDdlMarshStatus,odo_beg_fact,odo_end_fact,dt_beg_fact,dt_beg_plan,dt_end_fact,dt_end_plan,idTrailer,date_creation
         ,IDUsrPwd,PlanDistance,PlanCost,FactDistance,FactCost,Comment,dt_cancel,SubMarsh,SubFirstName,SubMiddleName,SubSurname,SubPass,SubDrvDoc,SubVehInfo,SubTrailerInfo
         ,SubPhone,'DEL'
  FROM [DELETED]
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'субподряд', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'SubMarsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата отмены', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dt_cancel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий если отменен', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'Comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость по рейсам', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'FactCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пробег по одометру', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'FactDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плановая стоимость', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'PlanCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плановый пробег', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'PlanDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор оператора', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'IDUsrPwd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'date_creation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор прицепа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'idTrailer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запланированная дата окончания рейса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dt_end_plan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания рейса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dt_end_fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запланированная дата выезда в рейс', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dt_beg_plan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата выезда в рейс', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dt_beg_fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Показание одометра на конец пути', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'odo_end_fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Показание одометра на начало пути', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'odo_beg_fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор статуса', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'IDdlMarshStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'IDdlDrivers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор ТС', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'IDdlVehicles';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор грузоперевозчика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarsh', @level2type = N'COLUMN', @level2name = N'dlMarshID';

