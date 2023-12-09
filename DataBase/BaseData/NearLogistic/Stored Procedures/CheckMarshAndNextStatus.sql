CREATE PROCEDURE NearLogistic.CheckMarshAndNextStatus
@mhID int,
@res bit out, 
@msg varchar(5000) out,
@op int =0
AS
BEGIN
  set @res=0
  set @msg=''
  
  declare @drID int
  declare @s_drID int
  declare @vID int
  declare @t_vID int
  declare @status int
  declare @TariffDrv int
  declare @TariffSpd int
  declare @profit money
  declare @dots bit
  
  select @drID=m.drId,
         @s_drID=m.SpedDrID,
         @vID=m.V_ID,
         @t_vID=m.V_idTr,
         @status=m.MStatus,
         @TariffDrv=m.nlTariffParamsIDDrv,
         @TariffSpd=m.nlTariffParamsIDSpd,
         @profit=NearLogistic.GetMarshProfit(@mhID),
         @dots=iif(exists(select 1 from NearLogistic.MarshRequests mr where mr.mhid=@mhID and mr.ReqType in (0,2)),1,0)
  from dbo.marsh m
  where m.mhID=@mhID
  
  if isnull(@drID,0)=0 set @msg=@msg+'- Укажите водителя;'+char(10)+char(13)
  if isnull(@vID,0)=0 set @msg=@msg+'- Укажите автомобиль;'+char(10)+char(13)
  --if isnull(@dots,0)=0 set @msg=@msg+'- Укажите точки развоза;'+char(10)+char(13)
  if isnull(@TariffDrv,0)=0 set @msg=@msg+'- Укажите тариф водителя;'+char(10)+char(13)
  if isnull(@s_drID,0)<>0
  if isnull(@TariffSpd,0)=0 set @msg=@msg+'- Укажите тариф экспедитора;'+char(10)+char(13)
  
  --добавить датувремя,оператора разрешения нерентабельного рейса
  --if @status>1
  --if @profit<0 set @msg=@msg+'- Рентабельность меньше 0;'+char(10)+char(13)
  
  set @res=iif(@msg<>'',1,0)
  
  if @res=0
  begin
   update m set m.MStatus=@status+1,
           m.AwayTime=iif(@status+1=3,getdate(),m.AwayTime),
                 m.Away=iif(@status+1=3,1,m.Away),
                 m.TimeGo=iif(@status+1=3,getdate(),m.TimeGo),
                 m.TimeBack=iif(@status+1=4,getdate(),m.TimeGo)
    from dbo.marsh m
    where m.mhid=@mhID
    
    declare @ids varchar(5000)
  
   select @ids=stuff((
        select N'#'+cast(mr.ReqID as varchar)+';'+cast(mr.ReqType as varchar)+';'+cast(mr.ReqAction as varchar)
              from NearLogistic.MarshRequests mr
              where mr.mhid=@mhid
              for xml path(''), type).value('.','varchar(max)'),1,0,'')
    
    insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType,remark) 
    values(@op,@mhid,@mhid,@ids,@ids,3,'Смена статуса на '+(select top 1 ms.msName from NearLogistic.MarshStatus ms where ms.msID=@status+1))
  end
END