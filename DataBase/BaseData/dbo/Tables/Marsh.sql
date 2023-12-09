CREATE TABLE [dbo].[Marsh] (
    [mhid]                INT             IDENTITY (1, 1) NOT NULL,
    [ND]                  DATETIME        NULL,
    [Marsh]               INT             NOT NULL,
    [Weight]              FLOAT (53)      NULL,
    [BoxQty]              FLOAT (53)      NULL,
    [Driver]              VARCHAR (80)    NULL,
    [Sped]                VARCHAR (50)    NULL,
    [Done]                TINYINT         DEFAULT (0) NULL,
    [Closed]              TINYINT         DEFAULT (0) NULL,
    [Dist]                FLOAT (53)      DEFAULT ((0)) NULL,
    [DistPay]             MONEY           DEFAULT ((0)) NULL,
    [Dohod]               MONEY           DEFAULT ((0)) NULL,
    [SpedPay]             MONEY           DEFAULT ((0)) NULL,
    [LgsId]               INT             NULL,
    [Hours]               FLOAT (53)      DEFAULT (0) NULL,
    [HoursPay]            MONEY           DEFAULT (0) NULL,
    [Marja]               MONEY           DEFAULT (0) NULL,
    [Dots]                INT             DEFAULT (0) NULL,
    [DotsPay]             MONEY           DEFAULT (0) NULL,
    [Minuts]              TINYINT         DEFAULT (0) NULL,
    [TimePlan]            CHAR (8)        CONSTRAINT [DF__Marsh__TimePlan__5852D887] DEFAULT ((0)) NULL,
    [TimeStart]           CHAR (8)        CONSTRAINT [DF__Marsh__TimeStart__5946FCC0] DEFAULT ((0)) NULL,
    [TimeFinish]          CHAR (8)        CONSTRAINT [DF__Marsh__TimeFinis__5A3B20F9] DEFAULT ((0)) NULL,
    [MarshDay]            SMALLINT        DEFAULT (0) NULL,
    [N_Driver]            SMALLINT        DEFAULT (0) NULL,
    [N_Sped]              SMALLINT        DEFAULT (0) NULL,
    [Vehicle]             VARCHAR (50)    CONSTRAINT [DF__Marsh__Vehicle__123EB7A3] DEFAULT ('') NULL,
    [MaxWeight]           INT             DEFAULT (0) NULL,
    [V_ID]                INT             CONSTRAINT [DF__Marsh__V_ID__32AB8735] DEFAULT (0) NULL,
    [FuelMark]            VARCHAR (10)    DEFAULT ('') NULL,
    [FuelCode]            VARCHAR (10)    DEFAULT ('') NULL,
    [Fuel0]               FLOAT (53)      DEFAULT (0) NULL,
    [Fuel1]               FLOAT (53)      DEFAULT (0) NULL,
    [FuelAdd]             FLOAT (53)      DEFAULT (0) NULL,
    [Km0]                 FLOAT (53)      DEFAULT (0) NULL,
    [Km1]                 FLOAT (53)      DEFAULT (0) NULL,
    [TimeGo]              DATETIME        NULL,
    [TimeBack]            DATETIME        CONSTRAINT [DF__Marsh__TimeBack__638F8109] DEFAULT (CONVERT([varchar],getdate(),(104))+' 00:00:00') NULL,
    [ForBrPay]            MONEY           DEFAULT (0) NULL,
    [ReadyDT]             DATETIME        NULL,
    [Bill]                MONEY           DEFAULT (0) NULL,
    [FuelAzs]             FLOAT (53)      DEFAULT (0.0) NULL,
    [DrvPay]              MONEY           DEFAULT ((0)) NULL,
    [CityFLG]             NUMERIC (1)     DEFAULT ((0)) NULL,
    [Stockman]            INT             DEFAULT ((0)) NULL,
    [WayPay]              MONEY           DEFAULT ((0)) NULL,
    [VetPay]              MONEY           DEFAULT ((0)) NULL,
    [BackTara]            INT             DEFAULT ((0)) NULL,
    [Away]                BIT             DEFAULT ((0)) NULL,
    [AwayTime]            DATETIME        NULL,
    [NDPrint]             DATETIME        NULL,
    [DelivCancel]         BIT             DEFAULT ((0)) NULL,
    [NotifyDrvTime]       VARCHAR (5)     NULL,
    [RatedArrivalTime]    VARCHAR (5)     NULL,
    [mState]              INT             DEFAULT ((0)) NULL,
    [NegProfit]           BIT             DEFAULT ((0)) NULL,
    [CalcDist]            FLOAT (53)      DEFAULT ((0)) NULL,
    [CalcTime]            VARCHAR (8)     DEFAULT ((0)) NULL,
    [V_idTr]              INT             DEFAULT ((0)) NULL,
    [TimePhoneCall]       CHAR (8)        CONSTRAINT [DF__Marsh__TimePhone__5C23696B] DEFAULT ((0)) NULL,
    [RtnTovFlg]           BIT             DEFAULT ((0)) NULL,
    [MoneyBack]           BIT             DEFAULT ((0)) NULL,
    [drId]                INT             DEFAULT ((0)) NULL,
    [DepId]               INT             DEFAULT ((0)) NULL,
    [GrMan]               INT             DEFAULT ((0)) NULL,
    [TsMan]               INT             DEFAULT ((0)) NULL,
    [Remark]              VARCHAR (100)   NULL,
    [Description]         VARCHAR (250)   NULL,
    [dopWeight]           FLOAT (53)      DEFAULT ((0)) NULL,
    [CalcRashod]          AS              ((([dots]*[dotspay]+[dist]*[distpay])+[DrvPay])+[SpedPay]),
    [ScanND]              DATETIME        NULL,
    [VedNo]               INT             DEFAULT ((0)) NULL,
    [BruttoWeight]        DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [PercWorkPay]         MONEY           DEFAULT ((0)) NULL,
    [Peni]                FLOAT (53)      CONSTRAINT [DF__Marsh__Peni__2E7C9A4C] DEFAULT ((0)) NOT NULL,
    [TmCallDrv]           CHAR (8)        CONSTRAINT [DF__Marsh__TmCallDrv__1CE7F9F6] DEFAULT ((0)) NULL,
    [VedNabPrinted]       INT             CONSTRAINT [DF__Marsh__VedNabPri__3084DE4F] DEFAULT ((0)) NULL,
    [TrfOpt]              BIT             DEFAULT ((0)) NULL,
    [SelfShip]            BIT             DEFAULT ((0)) NULL,
    [nlTariffParamsIDDrv] INT             DEFAULT ((0)) NULL,
    [nlTariffParamsIDSpd] INT             DEFAULT ((0)) NULL,
    [Direction]           VARCHAR (150)   NULL,
    [SpedDrID]            INT             DEFAULT ((0)) NULL,
    [ListNo]              INT             DEFAULT ((0)) NULL,
    [MStatus]             INT             DEFAULT ((0)) NULL,
    [ListNoSped]          INT             DEFAULT ((0)) NULL,
    [Volume]              MONEY           DEFAULT ((0)) NOT NULL,
    [Earnings]            MONEY           DEFAULT ((0)) NULL,
    [PLID]                INT             DEFAULT ((1)) NOT NULL,
    [PriorityFlag]        INT             DEFAULT ((0)) NOT NULL,
    [dt_create]           DATETIME        DEFAULT (getdate()) NOT NULL,
    [host_create]         VARCHAR (100)   DEFAULT (host_name()) NOT NULL,
    [max_liter_id]        INT             DEFAULT ((0)) NOT NULL,
    [LaID]                INT             DEFAULT ((0)) NULL,
    [parent_mhid]         INT             DEFAULT ((0)) NOT NULL,
    [hand_calc]           BIT             DEFAULT ((0)) NOT NULL,
    [point_id]            INT             DEFAULT ((21354)) NOT NULL,
    [LockBill]            BIT             DEFAULT ((0)) NOT NULL,
    [lock_remark]         VARCHAR (500)   NULL,
    PRIMARY KEY CLUSTERED ([mhid] ASC),
    CONSTRAINT [Marsh_ck] CHECK ([marsh]>(0))
);


GO
CREATE NONCLUSTERED INDEX [Marsh_idx2]
    ON [dbo].[Marsh]([ND] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Marsh_uq]
    ON [dbo].[Marsh]([ND] ASC, [Marsh] ASC);


GO
CREATE NONCLUSTERED INDEX [Marsh_idx3]
    ON [dbo].[Marsh]([ListNo] ASC);


GO
CREATE NONCLUSTERED INDEX [Marsh_idx]
    ON [dbo].[Marsh]([Marsh] ASC);


GO
CREATE TRIGGER dbo.trg_Marsh_u ON dbo.Marsh
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE, DELETE
AS
begin
	declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit, 
          @TN nvarchar(500), @ParmDefinition nvarchar(500), @mhID int, @type int
  
  if exists(select 1 from inserted) and exists(select 1 from deleted) set @type=0
  else
  if exists(select 1 from inserted) and not exists(select 1 from deleted) set @type=1
  else 
  set @type=2

  select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.mhid=i1.mhid    
  insert into #TempTable select 1 as nom,* from deleted

  declare @cursor_fields cursor  
  declare @cursor_records cursor        	

  set @cursor_fields  = cursor scroll
  for select name 
      from sys.columns 
      where object_id=object_id('dbo.marsh')     
  open @cursor_fields
        
  set @cursor_records  = cursor scroll
  for select distinct mhID
  		from #TempTable
  open @cursor_records
         
  fetch next from @cursor_records into @mhID

  while @@fetch_status = 0
  begin
    set @First=1
    fetch first from @cursor_fields into @FieldName
    
    while @@fetch_status = 0
    begin
      set @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
      set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0)'
      exec sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
                   
      set @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
      set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1)'
      exec sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
      
      if isnull(@Temp,'')<>isnull(@TempOLD,'')
      begin
        if @First=1
        begin
          insert into MarshRec(type,mhID)
          values (@type,@mhID)
          set @KD=scope_identity()
          set @First=0
        end
        	
        insert into MarshRecDET (ISPR,FieldName,Old_value,New_Value)
        values (@KD,@FieldName,@TempOLD,@Temp)
      end
      
      fetch next from @cursor_fields into @FieldName
    end

    fetch next from @cursor_records into @mhID
  end

  close @cursor_records
  deallocate @cursor_records

  close @cursor_fields
  deallocate @cursor_fields
end
GO
DISABLE TRIGGER [dbo].[trg_Marsh_u]
    ON [dbo].[Marsh];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прибыль', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Earnings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер ведомости для экспедиторов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'ListNoSped';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статус маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'MStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер ведомости', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'ListNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код экспедитора из Drivers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'SpedDrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Направление (название) маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Direction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тариф для расчета экспедитора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'nlTariffParamsIDSpd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тариф для расчета водителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'nlTariffParamsIDDrv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Самовывоз', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'SelfShip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оптовый тариф (0.7 от транспортных расходов)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TrfOpt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Счетчик распечаток ведомостей набора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'VedNabPrinted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время обзвона водителя до начала погрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TmCallDrv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'штраф водителю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Peni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если маршрут везет ИП то высчит сумма котор ему доплачиваеися за долгосрочное сотрудничество
если физ лицо то 0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'PercWorkPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вес брутто. Сумма NC.BruttoWeight', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'BruttoWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ ведомости оплаты из таблицы MarshVedOpl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'VedNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сканирования маршрутника архивом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'ScanND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный расчетный расход по маршруту', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'CalcRashod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'доп вес по маршруту (из 1С)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'dopWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание к километражу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наборщик К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TsMan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Грузчик К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'GrMan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к какому отделу относится маршрут', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'DepId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код водителя из табл Drivers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'drId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Везет ли водитель деньги из т. точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'MoneyBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Был ли возврат товара(с маршрута)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'RtnTovFlg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время отзвона водителя с последней торговой точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimePhoneCall';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'V_Id прицепа из табл Vehicle ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'V_idTr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетное время', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'CalcTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный километраж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'CalcDist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Флаг показывающий что маршрут разрешен с отрицательной прибылью', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'NegProfit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статус маршрута 
1- маршрут набран
2- разрешена печать
3- исправить', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'mState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетное время прибытия со слов водителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'RatedArrivalTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время уведом.водителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'NotifyDrvTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доставка маршрута отменена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'DelivCancel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата и время последней печати маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'NDPrint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время установки флага Away', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'AwayTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Машина уехала', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Away';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращено тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'BackTara';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата вет. документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'VetPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Платная дорога', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'WayPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кладовщик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Stockman';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак городского маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'CityFLG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата водителю ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'DrvPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма чека на горючее', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Bill';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время окончания развоза', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimeBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время выезда', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimeGo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Показания одометра после возвращения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Km1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Показания одометра перед выездом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Km0';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выдано горючего', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'FuelAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Остаток горючего при возвращении', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Fuel1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Остаток горючего при выезде', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Fuel0';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код марки горючего', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'FuelCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Марка горючего', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'FuelMark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код машины в табл. Vehicle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'V_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальный тоннаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'MaxWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код водителя в таблице Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'N_Driver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Конец загрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimeFinish';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начало загрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimeStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'План загрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'TimePlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минуты развоза', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Minuts';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за одну точку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'DotsPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во точек', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Dots';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка по маршруту', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Marja';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 часа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'HoursPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Часы развоза', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Hours';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код логиста создавшего маршрут', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'LgsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата экспедитору', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'SpedPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма SP по маршруту', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Dohod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 км', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'DistPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Километраж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Dist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Готов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Done';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Экспедитор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Sped';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Направление (устаревшее, к удалению) - новое Direction', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Driver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во коробок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'BoxQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тоннаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'Marsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0- нет
1- низкий
2- средний
3- высокий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh', @level2type = N'COLUMN', @level2name = N'mhid';

